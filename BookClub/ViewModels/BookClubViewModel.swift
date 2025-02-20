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

@MainActor
class BookClubViewModel: ObservableObject {
    @Published var createdClubs: [BookClub] = []  // store any created clubs fetched from firestore
    @Published var bookClub: BookClub?  // updated when tap club in clubs list - when fetch one book club
    @Published var moderatorName: String = ""

    // when a user creates a new book club - save to firebase
    func saveNewClub(name: String, description: String, genre: String, meetingType: String, isPublic: Bool, creationDate: Date) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("couldn't get the id")
            return
        }
        
        let db = Firestore.firestore()
        let bookClub = BookClub(name: name, moderatorId: userId, description: description, genre: genre, meetingType: meetingType, isPublic: isPublic, creationDate: creationDate)
        
        do {
            // make new document with info from bookClub object
            try db.collection("BookClub").document(bookClub.id.uuidString).setData(from: bookClub)
            
            print("saved new club details successfully")
        } catch {
            print("failed to save new club details")
        }
    }
    
    // fetch created book clubs from database - for 'created clubs' list
    func fetchCreatedBookClubs() async throws {
        print("fetch created club details")
        
        self.createdClubs.removeAll()  // empty array when try fetch information again - so doesn't duplicate
        
        // current user's userId - for fetching user's created book clubs
        guard let id = Auth.auth().currentUser?.uid else {
            print("couldn't get the id to fetch details")
            return
        }
        
        let db = Firestore.firestore()
        
        do {
            // fetch docs where moderatorId is the same as current userId
            let querySnapshot = try await db.collection("BookClub").whereField("moderatorId", isEqualTo: id).getDocuments()
            for document in querySnapshot.documents {
//                print("\(document.documentID) => \(document.data())")  // bookClubId => mapped data of that document
                
                // make object using BookClub model from document data
                let bookClub = try document.data(as: BookClub.self)
                // add book club to array
                self.createdClubs.append(bookClub)
            }
        } catch {
            print("error getting book club documents: \(error)")
        }
    }
    
    // when tap on a book club in clubs list
    func fetchOneBookClub(bookClubId: UUID) async throws {
        print("fetch one book club")
        
        let db = Firestore.firestore()
        // get document of book club with specified book club ID
        let docRef = db.collection("BookClub").document(bookClubId.uuidString)
        
        do {
            // try and get document for given docRef
            let document = try await docRef.getDocument()
            if document.exists {
                // create BookClub object from retrieved data
                let bookClub = try document.data(as: BookClub.self)
                self.bookClub = bookClub  // update @Published var with the book club
                print("document data: \(bookClub)")
            } else {
                print("document for book club \(bookClubId) doesn't exist")
            }
        } catch {
            print("error getting book club document: \(error.localizedDescription)")
        }
    }
    
    // get moderator name to show on book club details ui
    func fetchModeratorDetails(moderatorId: String) async throws {
        print("fetch moderator details")
        
        let db = Firestore.firestore()
        // find doc from Users collection with moderatorId
        let docRef = db.collection("User").document(moderatorId)
        
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                // create user object from doc data
                let user = try document.data(as: User.self)
                // save the moderator name for ui
                self.moderatorName = user.name
            } else {
                print("user document doesn't exist for this moderatorId: \(moderatorId)")
            }
        } catch {
            print("error getting moderatorId: \(error.localizedDescription)")
        }
    }
}
