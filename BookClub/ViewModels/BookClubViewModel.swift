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
        
        self.createdClubs.removeAll()  // empty array when try fetch information again
        
        // current user's userId - for fetching user's created book clubs
        guard let id = Auth.auth().currentUser?.uid else {
            print("couldn't get the id to fetch details")
            return
        }
        print("id: \(id)")
        
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
            
//            print(createdClubs)
        } catch {
            print("error getting book club documents: \(error)")
        }
    }
}
