//
//  SignUpView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var authValidationViewModel = AuthValidationViewModel()
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
                        ViewTemplates.signupTextField(placeholder: "Name", input: $authValidationViewModel.name, isSecureField: false, prompt: authValidationViewModel.namePrompt)
                            .focused($focusedField, equals: .name)
                            .onSubmit {
                                focusedField = .email
                            }
                        
                        ViewTemplates.signupTextField(placeholder: "Email", input: $authValidationViewModel.email, isSecureField: false, prompt: authValidationViewModel.emailPrompt)
                            .focused($focusedField, equals: .email)
                            .onSubmit {
                                focusedField = .password
                            }
                        
                        // password
                        HStack {
                            ViewTemplates.passwordSecureField(placeholder: "Password", input: $authValidationViewModel.password, showPassword: $showPassword)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .onChange(of: authValidationViewModel.password) {
                                    // show password message when start typing
                                    authValidationViewModel.showPasswordPrompt = true
                                }
                            
                            // show password entered
                            if !authValidationViewModel.password.isEmpty {
                                Button("SHOW") {
                                    showPassword.toggle()
                                    print("show button pressed")
                                }
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            }
                        }
                        
                        // visible when start typing password in gray
                        if authValidationViewModel.showPasswordPrompt {
                            Text("Password must be at least 6 characters and include an uppercase letter, number, and special character.")
                                .foregroundStyle(authValidationViewModel.passwordPromptColor)  // turns red if invalid
                                .font(.footnote)
                                .padding(.bottom, 5)
                        } else {
                            Text("")
                        }
                    }  // vstack
                    
                    // sign up button
                    Button {
                        if authValidationViewModel.isSignUpFormValid() {
                            Task {
                                // if form's valid try create new user with Firebase Auth
                                try await authViewModel.signUp(name: authValidationViewModel.name, email: authValidationViewModel.email, password: authValidationViewModel.password)
                            }
                        } else {
                            // show any error prompts for invalid field inputs
                            authValidationViewModel.showValidationErrors = true
                            authValidationViewModel.showPasswordPrompt = true
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
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
