//
//  SignUpView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var signUpViewModel: SignUpViewModel
    @FocusState private var focusedField: Field?  // to go between textfields when submit
    @State private var showPassword: Bool = false
    
    // textfields
    enum Field: Hashable {
        case name, email, password
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
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 20)
                
                VStack {
                    // textfields
                    VStack(alignment: .leading, spacing: 5) {
                        ViewTemplates.signupTextField(placeholder: "Name", input: $signUpViewModel.name, isSecureField: false, prompt: signUpViewModel.namePrompt)
                            .focused($focusedField, equals: .name)
                            .onSubmit {
                                focusedField = .email
                            }
                        
                        ViewTemplates.signupTextField(placeholder: "Email", input: $signUpViewModel.email, isSecureField: false, prompt: signUpViewModel.emailPrompt)
                            .focused($focusedField, equals: .email)
                            .onSubmit {
                                focusedField = .password
                            }
                        
                        // password
                        HStack {
                            ViewTemplates.passwordSecureField(placeholder: "Password", input: $signUpViewModel.password, showPassword: $showPassword)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .onChange(of: signUpViewModel.password) {
                                    // show password info when start typing
                                    signUpViewModel.showPasswordPrompt = true
                                }
                            
                            // show password entered
                            if !signUpViewModel.password.isEmpty {
                                Button("SHOW") {
                                    showPassword.toggle()
                                    print("show button pressed")
                                }
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            }
                        }

                        if signUpViewModel.showPasswordPrompt {
                            Text("Password must be at least 6 characters and include an uppercase letter, number, and special character.")
                                .foregroundStyle(signUpViewModel.passwordPromptColor)  // turns red if invalid
                                .font(.footnote)
                                .padding(.bottom, 5)
                        }
                    }  // vstack
                    
                    // sign up button
                    Button {
                        if signUpViewModel.isFormValid() {
                            Task {
                                // try create new user with Firebase Auth
                                try await authViewModel.signUp(name: signUpViewModel.name, email: signUpViewModel.email, password: signUpViewModel.password)
                            }
                        } else {
                            // show any errors for invalid field inputs
                            signUpViewModel.showValidationErrors = true
                            signUpViewModel.showPasswordPrompt = true
                        }
                    } label: {
                        Text("Sign up with email")
                            .loginSignupButtonStyle()
                    }
                    // alert only for if email is already in use
                    .alert(isPresented: $authViewModel.isEmailInUse) {
                        Alert(
                            title: Text("Email is already in use."),
                            message: Text("Please log in or use a different email.")
                        )
                    }
                }
                
                Spacer()
                
                // sign up buttons
                VStack {
                    Button {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    } label: {
                        Text("Continue with Apple")
                            .loginSignupButtonStyle()
                    }
                    
                    Button {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    } label: {
                        Text("Continue with Google")
                            .loginSignupButtonStyle()
                    }
                    .padding(.bottom, 20)
                    
                    // log in link
                    HStack(spacing: 5) {
                        Text("Already have an account?")
                        NavigationLink("Log in", destination: LoginView())
                            .fontWeight(.medium)
                            .foregroundStyle(.tint)
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
    SignUpView(signUpViewModel: SignUpViewModel())
        .environmentObject(AuthViewModel())
}
