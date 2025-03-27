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
import FirebaseStorage

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var userIsLoggedIn: Bool = false
    // for sign up
    @Published var isEmailInUse: Bool = false  // return if email already in use when sign up
    @Published var isNewUser: Bool = false  // go to onboarding if just signed up
    
    // choose random asset for default profile pic
    private var defaultIconStr: [String] = ["blueIcon", "yellowIcon", "pinkIcon", "greenIcon"]
    // store actual images here from storage
//    @Published var profilePics: [String: UIImage] = [:]  // [userId : UIImage]
    @Published var profilePic: UIImage?  // loaded profile pic for logged in user - fetchUser()
    
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
            
            // create instance of the db
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
    
    func saveOnboardingDetails(favouriteGenres: [String], location: String) async throws {
        // create instances of db and storage
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        // will be ref to image in storage
        let imageFilePath = "profilePictures/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(imageFilePath)
        
        do {
            guard let id = Auth.auth().currentUser?.uid else {
                print("couldn't get the uid to save onboarding details")
                return
            }
            
            // want to add to User collection
            let userRef = db.collection("User").document(id)
            try await userRef.setData([
                "favouriteGenres": favouriteGenres,
                "location": location,
                "joinedClubs": [],
                "profilePictureURL": imageFilePath
            ], merge: true)
            
            print("Successfully saved onboarding details to Firestore")
            
            // choose random image to set as default
            let profilePic = UIImage(named: defaultIconStr.randomElement() ?? "blueIcon")
            
            // add default image to storage
            if let imageData = profilePic?.jpegData(compressionQuality: 0.8) {
                _ = fileRef
                    .putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print(
                                "error saving image: \(error.localizedDescription)"
                            )
                        }
                    }
            }
            self.profilePic = profilePic

            print("profile pic saved successfully")
        } catch {
            print("Failed to save onboarding info: \(error.localizedDescription)")
        }
    }
    
    func logIn(email: String, password: String) async throws {
        print("sign in...")
        
        do {
            // try log in
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("log in successful")
            
            await fetchUser()
        } catch {
            print("Could not log in user: \(error.localizedDescription)")
        }
    }
    
    // get details of logged in user
    func fetchUser() async {
        print("Fetch user...")
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        
        // get uid created when user signed up - String
        guard let userId = Auth.auth().currentUser?.uid else {
            print("no user signed in")
            return
        }
        
        do {
            // get details of logged in user
            let snapshot = try? await db.collection("User").document(userId).getDocument()
            // create new instance of User with details from doc
            self.currentUser = try snapshot?.data(as: User.self)
            
            print("Current user is: \(String(describing: self.currentUser))")
            
            // get profile pic for logged in user
            let imageRef = storageRef.child(
                // path to image in storage
                self.currentUser?.profilePictureURL ?? ""
            )
            // get the image from storage
            imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print(
                        "error occured fetching image: \(error.localizedDescription)"
                    )
                } else if let data = data {
                    let image = UIImage(data: data)
                    // save profile pic to @Published var
                    self.profilePic = image
                }
            }
            
            print("fetched profile pic successfully")
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
            // reset properties
            userSession = nil
            currentUser = nil
            isNewUser = false
            print("sign out successful")
        } catch let signOutError as NSError {
            print("Error signing out:", signOutError)
        }
    }
}
