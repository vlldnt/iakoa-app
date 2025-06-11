//
//  ChangePasswordValidator.swift
//  IAKOA
//
//  Created by Adrien V on 10/06/2025.
//


import Foundation

struct ChangePasswordValidator {
    static func isValid(password: String) -> Bool {
        return password.count >= 8 &&
               containsUppercase(password) &&
               containsDigit(password)
    }

    static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return !confirmPassword.isEmpty && password == confirmPassword
    }

    private static func containsUppercase(_ text: String) -> Bool {
        let regex = ".*[A-Z]+.*"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }

    private static func containsDigit(_ text: String) -> Bool {
        let regex = ".*[0-9]+.*"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
}
