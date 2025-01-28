//
//  SignUpViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

// validation for when use tries to sign up

import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showValidationErrors: Bool = false  // changes to true after pressing sign up
    @Published var showPasswordPrompt: Bool = false

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
    
    func isFormValid() -> Bool {
        return !name.isEmpty && isEmailValid() && isPasswordValid()
    }
    
    // add check for if email in system already
    func isEmailValid() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        print("\(NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email))")
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isPasswordValid() -> Bool {
        // at least 1 upper case character, 1 number, 1 special character and must be at least 6 characters
        let passwordRegex = "((?=.*\\d)(?=.*[A-Z])(?=.*[\\W_]).{6,})"
        print("\(NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password))")
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}
