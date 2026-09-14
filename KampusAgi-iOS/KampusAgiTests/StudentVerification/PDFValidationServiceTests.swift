import XCTest
@testable import KampusAgi

final class PDFValidationServiceTests: XCTestCase {
    private let sut = PDFValidationService()

    func testValidPDFPasses() {
        var data = Data([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34])
        data.append(Data(repeating: 0, count: 100))

        XCTAssertEqual(sut.validate(data: data), .valid)
    }

    func testEmptyDataIsRejected() {
        XCTAssertEqual(sut.validate(data: Data()), .invalid(.empty))
    }

    func testNonPDFDataIsRejected() {
        // A JPEG magic-byte header — simulating a disallowed screenshot/photo upload (§7).
        let jpegHeader = Data([0xFF, 0xD8, 0xFF, 0xE0])
        XCTAssertEqual(sut.validate(data: jpegHeader), .invalid(.notPDF))
    }

    func testOversizedPDFIsRejected() {
        var data = Data([0x25, 0x50, 0x44, 0x46])
        data.append(Data(repeating: 0, count: AppConstants.Validation.maxDocumentSizeBytes + 1))

        XCTAssertEqual(sut.validate(data: data), .invalid(.tooLarge(maxBytes: AppConstants.Validation.maxDocumentSizeBytes)))
    }

    func testDataShorterThanMagicBytesIsRejected() {
        let data = Data([0x25, 0x50])
        XCTAssertEqual(sut.validate(data: data), .invalid(.notPDF))
    }
}
