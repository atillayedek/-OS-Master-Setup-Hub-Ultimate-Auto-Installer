import Foundation

extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidPassword: Bool {
        count >= AppConstants.Validation.minPasswordLength
    }

    var isValidDepartmentName: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= AppConstants.Validation.departmentMinLength
            && trimmed.count <= AppConstants.Validation.departmentMaxLength
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
