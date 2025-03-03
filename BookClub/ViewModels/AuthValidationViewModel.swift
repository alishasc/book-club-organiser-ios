//
//  AuthValidationViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 24/02/2025.
//

// for checking validation of login and signup forms

import Foundation
import SwiftUI

@MainActor
class AuthValidationViewModel: ObservableObject  {
    @Published var name: String = ""  // only on sign up
    @Published var email: String = ""
    @Published var password: String = ""
    // changes to true after pressing login/sign up
    @Published var showValidationErrors: Bool = false
    @Published var showPasswordPrompt: Bool = false  // for signup

    // set error message to show if invalid fields
    var namePrompt: String {
        if showValidationErrors && name.isEmpty {
            return "Required"
        } else {
            return ""
        }
    }

    var emailPrompt: String {
        if showValidationErrors && !isEmailValid() {
            return "Invalid email address"
        } else {
            return ""
        }
    }

    var passwordPromptColor: Color {
        if showValidationErrors && !isPasswordValid() {
            return .red
        } else {
            return .gray
        }
    }
    
    var invalidLoginPrompt: String {
        if showValidationErrors && !isLoginFormValid() {
            return "Invalid email or password"
        } else {
            return ""
        }
    }

    func isEmailValid() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    func isPasswordValid() -> Bool {
        // at least 1 upper case character, 1 number, 1 special character and must be at least 6 characters
        let passwordRegex = "((?=.*\\d)(?=.*[A-Z])(?=.*[\\W_]).{6,})"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    func isLoginFormValid() -> Bool {
        return isEmailValid() && isPasswordValid()
    }
    
    func isSignUpFormValid() -> Bool {
        return !name.isEmpty && isEmailValid() && isPasswordValid()
    }
}
