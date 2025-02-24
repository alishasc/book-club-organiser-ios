//
//  LoginView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var focusedField: Field?  // to go between textfields when submit
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    // textfields
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // image and title
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                    Text("Welcome Back!")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 20)
                
                // textfields & forgot password
                VStack(alignment: .leading, spacing: 5) {
                    // email
                    ViewTemplates.textField(placeholder: "Email", input: $email, isSecureField: false)
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            focusedField = .password
                        }
                    
                    // invalid email message
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
                        
                        // show password input
                        if !password.isEmpty {
                            Button("SHOW") {
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
                    .foregroundStyle(.accent)
                }
                .padding(.bottom, 20)
                
                // login buttons
                VStack {
                    Button {
                        print("login button tapped")
                        
                        // only try login if form is complete
                        if !email.isEmpty && !password.isEmpty {
                            Task {
                                try await authViewModel.logIn(email: email, password: password)
                            }
                        }
                    } label: {
                        Text("Log in with email")
                            .loginSignupButtonStyle()
                    }
                    
                    Spacer()
                    
                    // login with apple
                    Button {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    } label: {
                        Text("Continue with Apple")
                            .loginSignupButtonStyle()
                    }
                    
                    // login with google
                    Button {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    } label: {
                        Text("Continue with Google")
                            .loginSignupButtonStyle()
                    }
                    .padding(.bottom, 20)
                    
                    // link to sign up page
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
        .environmentObject(AuthViewModel())
}
