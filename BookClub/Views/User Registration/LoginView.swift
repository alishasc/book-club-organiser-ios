//
//  LoginView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct LoginView: View {
    enum Field: Hashable {
        case email, password
    }
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var focusedField: Field?  // to go between textfields
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // image and title
                VStack(spacing: 20) {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                    Text("Welcome Back!")
                        .font(.title)
                        .fontWeight(.semibold)
                    //                    .padding(.bottom, 20)
                }
                .padding(.bottom, 20)
                
                // textfields / forgot password
                VStack(alignment: .leading, spacing: 5) {
                    // email
                    ViewTemplates.loginTextField(placeholder: "Email", input: $email, isSecureField: false)
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            focusedField = .password
                        }
                    
                    Text(authViewModel.invalidEmailPrompt)
                        .foregroundStyle(.red)
                        .font(.footnote)
                    
                    //password
                    HStack {
                        ViewTemplates.passwordSecureField(placeholder: "Password", input: $password, showPassword: $showPassword)
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                focusedField = nil
                            }
                        
                        if !password.isEmpty {
                            Button("SHOW") {
                                // tap to show input entered
                                showPassword.toggle()
                            }
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                        }
                    }
                    
                    // either email or password is incorrect - error message
                    if authViewModel.invalidCredentialPrompt != "" {
                        Text(authViewModel.invalidCredentialPrompt)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    
                    Button("Forgot password?") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.tint)
                    .padding(.bottom, 10)
                }
                .padding(.bottom, 10)
                
                // login buttons
                VStack {
                    Button("Log In with Email") {
                        print("login button tapped")
                        
                        if !email.isEmpty && !password.isEmpty {
                            Task {
                                try await authViewModel.logIn(email: email, password: password)
                            }
                        }
                    }
                    .loginSignupButtonStyle()
                    
                    Spacer()
                    
                    Button("Continue with Apple") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .loginSignupButtonStyle()
                    
                    Button("Continue with Google") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .loginSignupButtonStyle()
                    .padding(.bottom, 20)
                    
                    HStack(spacing: 5) {
                        Text("Don't have an account?")
                        NavigationLink(destination: SignUpView(signUpViewModel: SignUpViewModel())) {
                            Text("Sign up")
                                .fontWeight(.medium)
                                .foregroundStyle(.tint)
                        }
                    }
                    .font(.subheadline)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
}
