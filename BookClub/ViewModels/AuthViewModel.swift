//
//  AuthViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var userIsLoggedIn = false
    @Published var invalidEmailPrompt = ""
    @Published var invalidCredentialPrompt = ""
    @Published var isEmailInUse = false  // return if email already in use when sign up
    @Published var isNewUser: Bool = false  // go to onboarding if just signed up

    init() {
        self.userSession = Auth.auth().currentUser
        // if logged in
        if let userSessionNew = userSession {
            print(userSessionNew)
        } else {
            print("No active userSession")
        }
        
        // try and load user information
        Task {
            await fetchUser()
        }
    }
    
    func signUp(email: String, password: String) async throws {
        print("sign up...")
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            isNewUser = true  // flag to trigger onboarding
            print("sign up successful")
        } catch {
            print("Failed to create user: \(error.localizedDescription)")
            if error.localizedDescription == "The email address is already in use by another account." {
                isEmailInUse = true
            }
        }
    }
    
    func logIn(email: String, password: String) async throws {
        print("sign in...")
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("log in successful")
            await fetchUser()
        } catch let error as NSError {
            // check possible error codes returned
            if let errorCode = AuthErrorCode(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:  // checks if input is a string
                    self.invalidEmailPrompt = "Invalid email"
                    print("Invalid email")
                case .invalidCredential:  // email or password is wrong
                    self.invalidCredentialPrompt = "Email or password is incorrect. Please try again"
                    print("Email or password is incorrect")
                default:
                    print("Failed to sign in user: \(error.code) - \(error.localizedDescription)")
                }
            }
        }
    }
    
    // get details of logged in user
    func fetchUser() async {
        print("Fetch user...")
        
        // get uid created when user signed up
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no user signed in")
            return
        }
        print("uid: \(uid)")
        
        do {
            let snapshot = try? await Firestore.firestore().collection("User").document(uid).getDocument()
            self.currentUser = try snapshot?.data(as: User.self)
            
            print("Current user is: \(String(describing: self.currentUser))")
        } catch {
            print("Could not fetch user: \(error.localizedDescription)")
        }
    }
    
    // create User after onboarding
    func addNewUser(name: String, email: String, favouriteGenres: [String], location: GeoPoint?) {
        print("add new user...")
        
        // use the same uid as what was generated during sign up
        guard let uid = Auth.auth().currentUser?.uid else {
            print("couldn't get the uid to add new user")
            return
        }
        print("new user uid: \(uid)")
        
        // create instance of Firestore
        let db = Firestore.firestore()
        // create instance of User to create new document in Firebase
        let user = User(id: uid, name: name, email: email, favouriteGenres: favouriteGenres, location: location)
        
        do {
            // try make new document
            try db.collection("User").document(user.id).setData(from: user)
        } catch let error {
            print("Error writing new user to Firestore: \(error.localizedDescription)")
        }
    }
    
    // check first version of code
    func logOut() {
        print("sign out...")
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("sign out successful")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
