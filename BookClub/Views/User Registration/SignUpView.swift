//
//  SignUpView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct SignUpView: View {
    enum Field: Hashable {
        case name, email, password
    }
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var signUpViewModel: SignUpViewModel
    @FocusState private var focusedField: Field?  // to go between textfields
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
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 20)
                
                // textfields
                VStack(alignment: .leading, spacing: 5) {
                    // textfields
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
                        
                        if !signUpViewModel.password.isEmpty {
                            Button("SHOW") {
                                // tap to show input entered
                                showPassword.toggle()
                                print("show button pressed")
                            }
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        }
                    }
                    Text(signUpViewModel.passwordPrompt)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }  // vstack
                .padding(.bottom, 10)

                // sign up buttons
                VStack {
                    Button("Sign up with Email") {
                        if signUpViewModel.isFormValid() {
                            print("All fields valid")
                            Task {
                                try await authViewModel.signUp(email: signUpViewModel.email, password: signUpViewModel.password)
                            }
                        } else {
                            signUpViewModel.showValidationErrors = true
                        }
                    }
                    .loginSignupButtonStyle()
                    // alert only for if email is already in use
                    .alert(isPresented: $authViewModel.isEmailInUse) {
                        Alert(
                            title: Text("Email is already in use."),
                            message: Text("Please log in or use a different email.")
                        )
                    }
                    
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
