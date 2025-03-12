//
//  BookClubViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 12/02/2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@MainActor
class BookClubViewModel: ObservableObject {
    @Published var createdClubs: [BookClub] = []  // store any created clubs fetched from firestore
    @Published var bookClub: BookClub?  // updated when tap club in clubs list - when fetch one book club
    @Published var moderatorName: String = ""
    @Published var coverImages: [UUID: UIImage] = [:]  // bookClubId : UIImage for the cover image
    
    init() {
        Task {
            try await fetchCreatedBookClubs()
        }
    }
    
    // for creating new club
    let genreChoices: [String] = ["Art & Design", "Biography", "Business", "Children's Fiction", "Classics", "Contemporary", "Education", "Fantasy", "Food", "Graphic Novels", "Historical Fiction", "History", "Horror", "Humour", "LGBTQ+", "Mystery", "Music", "Myths & Legends", "Nature & Environment", "Personal Growth", "Poetry", "Politics", "Psychology", "Religion & Spirituality", "Romance", "Science", "Science-Fiction", "Short Stories", "Sports", "Technology", "Thriller", "Travel", "True Crime", "Wellness", "Young Adult"]
    
    // when a user creates a new book club - save to database and cloud storage
    func saveNewClub(name: String, coverImage: UIImage, description: String, genre: String, meetingType: String, isPublic: Bool) async throws {
        print("cover image UUID: \(coverImage)")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("couldn't get the user id")
            return
        }
        
        let bookClubId = UUID()
        // database
        let db = Firestore.firestore()
        // storage
        let storageRef = Storage.storage().reference()
        let imageFilePath = "clubCoverImages/\(UUID().uuidString).jpg"  // ref to save to database
        let fileRef = storageRef.child(imageFilePath)
        
        // upload image to storage
        if let imageData = coverImage.jpegData(compressionQuality: 0.8) {
            _ = fileRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error saving image: \(error!.localizedDescription)")
                } else {
                    print("successfully uploaded image")
                }
            }
        }
        
        // create new instance of BookClub
        let bookClub = BookClub(id: bookClubId, name: name, moderatorId: userId, coverImageURL: imageFilePath, description: description, genre: genre, meetingType: meetingType, isPublic: isPublic, creationDate: Date.now)
        
        // add new book club to database
        do {
            // make new document with info from bookClub
            try db.collection("BookClub").document(bookClub.id.uuidString).setData(from: bookClub)
            
            self.bookClub = bookClub
            self.createdClubs.append(bookClub)
            try await fetchBookClubDetails(bookClubId: bookClub.id)  // to get moderator name
        } catch {
            print("failed to save new club details: \(error.localizedDescription)")
        }
        
        try await retrieveCoverImage(bookClubId: bookClubId)  // get cover image - save in dict
    }
    
    func retrieveCoverImage(bookClubId: UUID) async throws {
        let db = Firestore.firestore()
        
        // get book club doc that matches the bookClubId
        let docRef = db.collection("BookClub").document(bookClubId.uuidString)
        
        do {
            // new instance of BookClub
            let bookClub = try await docRef.getDocument(as: BookClub.self)
            
            // where to find the image
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child(bookClub.coverImageURL)  // file you're looking for
            
            // try and get the image
            imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error occured fetching image: \(error.localizedDescription)")
                } else if let data = data {
                    let image = UIImage(data: data)
                    // bookClubId and matching cover image to dictionary
                    self.coverImages[bookClub.id] = image
                }
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }

    
    // fetch created book clubs and their cover images
    func fetchCreatedBookClubs() async throws {
        print("fetch created club details")
        // reset array/dict when fetch information again - no duplicates
        self.createdClubs.removeAll()
        self.coverImages.removeAll()
        
        // current user's userId - for fetching user's created book clubs
        guard let id = Auth.auth().currentUser?.uid else {
            print("couldn't get the id to fetch details")
            return
        }
        
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        
        do {
            // fetch docs where moderatorId is the same as current userId
            let querySnapshot = try await db.collection("BookClub").whereField("moderatorId", isEqualTo: id).getDocuments()
            
            for document in querySnapshot.documents {
                // make object using BookClub model from document data
                let bookClub = try document.data(as: BookClub.self)
                self.createdClubs.append(bookClub)
                
                let imageRef = storageRef.child(bookClub.coverImageURL)  // file you're looking for
                // get the image for each book club
                imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error occured fetching image: \(error.localizedDescription)")
                    } else if let data = data {
                        let image = UIImage(data: data)
                        // bookClubId and matching cover image to dictionary
                        self.coverImages[bookClub.id] = image
                    }
                }
            }
        } catch {
            print("error getting book club documents: \(error)")
        }
    }
    
    // get club and moderator details of selected book club
    func fetchBookClubDetails(bookClubId: UUID) async throws {
        print("fetch book club details")
        
        let db = Firestore.firestore()
        let clubDocRef = db.collection("BookClub").document(bookClubId.uuidString)
        
        // try get selected book club from BookClub collection
        do {
            let document = try await clubDocRef.getDocument()
            if document.exists {
                // create BookClub object from retrieved data
                let bookClub = try document.data(as: BookClub.self)
                self.bookClub = bookClub  // update @Published var with the book club
            } else {
                print("document for book club \(bookClubId) doesn't exist")
            }
        } catch {
            print("error getting book club document: \(error.localizedDescription)")
        }
        
        // try get moderator name from User collection
        if let bookClub = self.bookClub {
            let userDocRef = db.collection("User").document(bookClub.moderatorId)
            
            do {
                let document = try await userDocRef.getDocument()
                if document.exists {
                    // create user object from doc data
                    let user = try document.data(as: User.self)
                    // save the moderator name for ui
                    self.moderatorName = user.name
                } else {
                    print("user document doesn't exist for this moderatorId: \(bookClub.moderatorId)")
                }
            } catch {
                print("error getting moderatorId: \(error.localizedDescription)")
            }
        }
    }
    
    // ref: https://stackoverflow.com/questions/42822838/how-to-get-the-number-of-real-words-in-a-text-in-swift
    func getWordCount(str: String) -> Int {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = str.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        return words.count
    }
    
    
    
    
    
    
    
    
    
    // add image to storage and its ref to Firestore - not used when create new club
    func uploadPhoto(bookClubId: UUID, coverImage: UIImage) async throws {
        // location for storing image
        let storageRef = Storage.storage().reference()
        let imageFilePath = "clubCoverImages/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(imageFilePath)
        
        // try and save image to firebase storage
        if let imageData = coverImage.jpegData(compressionQuality: 0.8) {
            _ = fileRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error saving image: \(error!.localizedDescription)")
                } else {
                    print("successfully uploaded image")
                }
            }
        }
        
        // save image ref to firestore - in doc for selected book club
        let db = Firestore.firestore()
        let bookClubRef = db.collection("BookClub").document(bookClubId.uuidString)
        
        do {
            try await bookClubRef.setData(["coverImageURL": imageFilePath], merge: true)
            print("image ref added to firebase")
        } catch {
            print("error saving image ref: \(error.localizedDescription)")
        }
    }
}
