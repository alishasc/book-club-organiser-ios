//
//  ViewTemplates.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

// ref: https://github.com/happyiosdeveloper/swiftui-tagview?tab=readme-ov-file

import SwiftUI

class ViewTemplates {
    static func textField(placeholder: String, input: Binding<String>, isSecureField: Bool) -> some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .fontWeight(.medium)
            TextField("", text: input)
            Divider()
        }
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .submitLabel(.next)
    }
    
    static func signupTextField(placeholder: String, input: Binding<String>, isSecureField: Bool, prompt: String) -> some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .fontWeight(.medium)
            TextField("", text: input)
            Divider()
            Text(prompt)
                .foregroundStyle(.red)
                .font(.footnote)
        }
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .submitLabel(.next)
    }
    
    static func passwordSecureField(placeholder: String, input: Binding<String>, showPassword: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .fontWeight(.medium)
            
            if showPassword.wrappedValue {
                TextField("", text: input)
            } else {
                SecureField("", text: input)
            }
            
            Divider()
        }
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .submitLabel(.done)
    }
    
    // on home and explore pages
    static func bookClubRow(clubName: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .foregroundStyle(.quaternary)
                .frame(width: 240, height: 150)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
            Text("Book Club Name")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading, 15)
                .padding(.bottom, 10)
        }
    }
    
    struct loginSignupButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundStyle(.white)  // text colour
                .padding(.vertical, 10)
                .frame(minWidth: 340)
                .background(.tint)
                .clipShape(Capsule())
        }
    }
    
    struct onboardingButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundStyle(.white)  // text colour
                .padding(.vertical, 10)
                .frame(minWidth: 240)
                .background(.tint)
                .clipShape(Capsule())
        }
    }
}

extension View {
    func loginSignupButtonStyle() -> some View {
        modifier(ViewTemplates.loginSignupButtonModifier())
    }
}

extension View {
    func onboardingButtonStyle() -> some View {
        modifier(ViewTemplates.onboardingButtonModifier())
    }
}
