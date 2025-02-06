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
import MapKit

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
    
    func signUp(name: String, email: String, password: String) async throws {
        print("sign up...")
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            isNewUser = true  // flag to trigger onboarding
            print("sign up successful")
            
            guard let id = Auth.auth().currentUser?.uid else {
                print("couldn't get the uid to add new user")
                return
            }
            // create instance of Firestore
            let db = Firestore.firestore()
            // try save sign up details to new document
            do {
                try await db.collection("User").document(id).setData([
                    "id": id,
                    "name": name,
                    "email": email
                ])
                
                print("successfully added new user details to Firestore")
            } catch {
                print("Error writing sign up info to Firestore: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to create user: \(error.localizedDescription)")
            if error.localizedDescription == "The email address is already in use by another account." {
                isEmailInUse = true
            }
        }
    }
    
    func saveOnboardingDetails(favouriteGenres: [String], location: MKMapItem) async throws {
        do {
            guard let id = Auth.auth().currentUser?.uid else {
                print("couldn't get the uid to save onboarding details")
                return
            }
            
            // create instance of Firestore
            let db = Firestore.firestore()
            
            let userRef = db.collection("User").document(id)
            
            // convert location to GeoPoint
            let geoPoint = GeoPoint(latitude: location.placemark.coordinate.latitude, longitude: location.placemark.coordinate.longitude)
            
            try await userRef.setData([
                "favouriteGenres": favouriteGenres,
                "location": geoPoint
            ], merge: true)
            
            print("Successfully saved onboarding details to Firestore")
        } catch {
            print("Failed to save onboarding info: \(error.localizedDescription)")
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
        guard let id = Auth.auth().currentUser?.uid else {
            print("no user signed in")
            return
        }
        print("id: \(id)")
        
        do {
            let snapshot = try? await Firestore.firestore().collection("User").document(id).getDocument()
            self.currentUser = try snapshot?.data(as: User.self)
            
            print("Current user is: \(String(describing: self.currentUser))")
        } catch {
            print("Could not fetch user: \(error.localizedDescription)")
        }
    }
    
    // check first version of code
    func logOut() {
        print("sign out...")
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // reset vars
            userSession = nil
            currentUser = nil
            isNewUser = false
            print("sign out successful")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
