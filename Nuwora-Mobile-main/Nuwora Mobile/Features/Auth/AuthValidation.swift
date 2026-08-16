import Foundation

struct AuthValidator {
    private static let emailPattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
    static let minimumPasswordLength = 8

    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return false }
        return trimmed.range(of: emailPattern, options: .regularExpression) != nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= minimumPasswordLength
    }

    static func isLoginStepValid(email: String, password: String) -> Bool {
        isValidEmail(email) && password.isEmpty == false
    }

    static func isRegisterStepValid(email: String, password: String, confirmPassword: String) -> Bool {
        isValidEmail(email) && isValidPassword(password) && password == confirmPassword
    }

    static func loginValidationMessage(email: String, password: String) -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty && password.isEmpty {
            return nil
        }
        if isValidEmail(trimmedEmail) == false {
            return "Enter a valid email address."
        }
        if password.isEmpty {
            return "Enter your password."
        }
        return nil
    }

    static func registerValidationMessage(email: String, password: String, confirmPassword: String) -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty && password.isEmpty && confirmPassword.isEmpty {
            return nil
        }
        if isValidEmail(trimmedEmail) == false {
            return "Enter a valid email address."
        }
        if isValidPassword(password) == false {
            return "Password must be at least \(minimumPasswordLength) characters."
        }
        if password != confirmPassword {
            return "Passwords don't match."
        }
        return nil
    }
}
