//
//  LoginView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var authValidationViewModel = AuthValidationViewModel()
    @FocusState private var focusedField: Field?  // to go between textfields when submit
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
                    ViewTemplates.signupTextField(placeholder: "Email", input: $authValidationViewModel.email, isSecureField: false, prompt: "")
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            focusedField = .password
                        }
                        .onChange(of: authValidationViewModel.email) {
                            // hide error message if its showing
                            authValidationViewModel.showValidationErrors = false
                        }

                    //password
                    HStack {
                        ViewTemplates.passwordSecureField(placeholder: "Password", input: $authValidationViewModel.password, showPassword: $showPassword)
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                focusedField = nil
                            }
                            .onChange(of: authValidationViewModel.password) {
                                // hide error message if its showing
                                authValidationViewModel.showValidationErrors = false
                            }
                        
                        // show password input
                        if !authValidationViewModel.password.isEmpty {
                            Button("SHOW") {
                                showPassword.toggle()
                            }
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                        }
                    }

                    Button("Forgot password?") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.accent)
                    
                    // show message if login fails - 'invalid email or password'
                    Text(authValidationViewModel.invalidLoginPrompt)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                .padding(.bottom, 10)
                
                // login buttons
                VStack {
                    Button {
                        // only try login if form is complete
                        if authValidationViewModel.isLoginFormValid() {
                            Task {
                                try await authViewModel.logIn(email: authValidationViewModel.email, password: authValidationViewModel.password)
                            }
                        } else {
                            // show any error prompts for invalid field inputs
                            authValidationViewModel.showValidationErrors = true
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
                        NavigationLink(destination: SignUpView()) {
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
