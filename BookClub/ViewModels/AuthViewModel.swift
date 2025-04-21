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
    @Published var isNewUser: Bool = false  // trigger onboarding
    
    // choose random asset for default profile pic
    private var defaultIconStr: [String] = ["fantasyIcon", "mysteryIcon", "romanceIcon", "scifiIcon"]
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
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            isNewUser = true  // flag to trigger onboarding
            
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
                print("Couldn't get the uid to save onboarding details")
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
            
            // choose random image to set as default
            let profilePic = UIImage(named: defaultIconStr.randomElement() ?? "fantasyIcon")
            
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
        } catch {
            print("Failed to save onboarding info: \(error.localizedDescription)")
        }
    }
    
    func loginAndLoadData(email: String, password: String, bookClubViewModel: BookClubViewModel, eventViewModel: EventViewModel) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            
            // fetch data after logging in
            try await bookClubViewModel.fetchBookClubs()
            try await bookClubViewModel.fetchJoinedClubs()
            try await eventViewModel.fetchEvents()
            try await bookClubViewModel.getMessageUserList()
        } catch {
            print("Could not log in user: \(error.localizedDescription)")
        }
    }
    
    // get details of logged in user
    func fetchUser() async {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        
        // get uid created when user signed up - String
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is signed in")
            return
        }
        
        do {
            // get details of logged in user
            let snapshot = try? await db.collection("User").document(userId).getDocument()
            // create new instance of User with details from doc
            self.currentUser = try snapshot?.data(as: User.self)
            
            // get profile pic for logged in user
            let imageRef = storageRef.child(
                // path to image in storage
                self.currentUser?.profilePictureURL ?? ""
            )
            // get the image from storage
            imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                if let error = error {
                    print(
                        "error occured fetching user's profile picture: \(error.localizedDescription)"
                    )
                } else if let data = data {
                    let image = UIImage(data: data)
                    // save profile pic to @Published var
                    self.profilePic = image
                }
            }
        } catch {
            print("Could not fetch user: \(error.localizedDescription)")
        }
    }
    
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // reset properties
            userSession = nil
            currentUser = nil
            isNewUser = false
        } catch let signOutError as NSError {
            print("Error signing out:", signOutError)
        }
    }
    
    func updateDetails(name: String, email: String, favouriteGenres: [String], location: String, profilePicture: UIImage) async throws {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        guard let id = Auth.auth().currentUser?.uid else { return }
        var updatedData: [String: Any] = [:]
        
        if name != currentUser?.name {
            updatedData["name"] = name
        }
        if email != currentUser?.email {
            updatedData["email"] = email
            // send email to user to update email
            Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email) { error in
                if let error = error {
                    print(
                        "error sending email verification: \(error.localizedDescription)"
                    )
                    return
                }
            }
        }
        if favouriteGenres != currentUser?.favouriteGenres {
            updatedData["favouriteGenres"] = favouriteGenres
        }
        if location != currentUser?.location {
            updatedData["location"] = location
        }
        
        if profilePicture != self.profilePic {
            // create the image url for the db
            let imageFilePath = "profilePictures/\(UUID().uuidString).jpg"
            let fileRef = storageRef.child(imageFilePath)
            updatedData["profilePictureURL"] = imageFilePath  // to save to db
            
            // add new image to storage
            if let imageData = profilePicture.jpegData(compressionQuality: 0.8) {
                _ = fileRef
                    .putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print(
                                "error saving updated image: \(error.localizedDescription)"
                            )
                        }
                    }
            }
            
            // delete old image
            let oldImageRef = storageRef.child(self.currentUser?.profilePictureURL ?? "")

            do {
                try await oldImageRef.delete()
            } catch {
                print("error deleting old image: \(error.localizedDescription)")
            }
            
            self.profilePic = profilePicture
        }
        
        do {
            // update info in db
            try await db.collection("User").document(id).setData(updatedData, merge: true)
        } catch {
            print("error updating user details: \(error.localizedDescription)")
        }
                
        // update currentUser
        Task {
            await fetchUser()
        }
    }
}
