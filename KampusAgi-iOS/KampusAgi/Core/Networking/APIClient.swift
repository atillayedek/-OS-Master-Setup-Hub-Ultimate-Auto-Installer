import Foundation

protocol APIClient: Sendable {
    func send<Response: Decodable>(_ endpoint: APIEndpoint, as type: Response.Type) async throws -> Response
    func send(_ endpoint: APIEndpoint) async throws
    func upload<Response: Decodable>(
        _ endpoint: APIEndpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String,
        formFields: [String: String],
        as type: Response.Type
    ) async throws -> Response
}

extension APIClient {
    func upload<Response: Decodable>(
        _ endpoint: APIEndpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String,
        as type: Response.Type
    ) async throws -> Response {
        try await upload(endpoint, fileData: fileData, fileName: fileName, mimeType: mimeType, fieldName: fieldName, formFields: [:], as: type)
    }
}

/// URLSession-backed implementation. Talks only to `AppEnvironment.apiBaseURL`
/// (the app's own backend) — never directly to Firebase's REST APIs or to
/// Gemini, per §25.
final class URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: AuthTokenProviding
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: URL,
        tokenProvider: AuthTokenProviding,
        session: URLSession = .shared,
        decoder: JSONDecoder = .kampusAgiDefault,
        encoder: JSONEncoder = .kampusAgiDefault
    ) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func send<Response: Decodable>(_ endpoint: APIEndpoint, as type: Response.Type) async throws -> Response {
        let (data, _) = try await execute(endpoint)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            AppLogger.network.error("Decoding failed for \(endpoint.path, privacy: .public)")
            throw APIError.decoding
        }
    }

    func send(_ endpoint: APIEndpoint) async throws {
        _ = try await execute(endpoint)
    }

    func upload<Response: Decodable>(
        _ endpoint: APIEndpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String,
        formFields: [String: String] = [:],
        as type: Response.Type
    ) async throws -> Response {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        for (name, value) in formFields {
            body.append("--\(boundary)\r\n".utf8Data)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8Data)
            body.append("\(value)\r\n".utf8Data)
        }

        body.append("--\(boundary)\r\n".utf8Data)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".utf8Data)
        body.append("Content-Type: \(mimeType)\r\n\r\n".utf8Data)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".utf8Data)

        var multipartEndpoint = endpoint
        multipartEndpoint.body = body
        multipartEndpoint.headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"

        let (data, _) = try await execute(multipartEndpoint, timeout: AppConstants.Network.uploadTimeout)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    @discardableResult
    private func execute(_ endpoint: APIEndpoint, timeout: TimeInterval = AppConstants.Network.requestTimeout) async throws -> (Data, HTTPURLResponse) {
        let url = try endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if endpoint.body != nil, request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if endpoint.requiresAuth {
            let token = try await tokenProvider.currentIDToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw APIError.cancelled
        } catch {
            throw APIError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.transport("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            return (data, httpResponse)
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
            throw APIError.rateLimited(retryAfter: retryAfter)
        default:
            let message = String(data: data, encoding: .utf8)
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}

extension JSONDecoder {
    static var kampusAgiDefault: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension JSONEncoder {
    static var kampusAgiDefault: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
