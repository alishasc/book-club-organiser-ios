//
//  BookViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 19/02/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
class BookViewModel: ObservableObject {
    @Published var fetchedBook: Book?  // loaded from db
    @Published var booksList: [Book] = []  // when search for books
    @Published var selectedBook: Book?  // when search for books
    
    // search results
    func fetchBooksList(searchQuery: String) async throws {
        let bookUrlString = "https://www.googleapis.com/books/v1/volumes?q=\(searchQuery)&maxResults=15&key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"
        
        guard let bookUrl = URL(string: bookUrlString) else {
            fatalError("Invalid URL: \(bookUrlString)")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: bookUrl)
            let decoder = JSONDecoder()

            let bookResponse = try decoder.decode(BookResponse.self, from: data)
            self.booksList = bookResponse.items
            print("decoded multiple books")
        } catch {
            print("failed to load book data: \(error.localizedDescription)")
        }
    }
    
    // add book to db
    func saveBook(bookClubId: UUID, book: Book) async throws {
        print("save book to db")
                
        do {
            let db = Firestore.firestore()
            try db.collection("Book").document(bookClubId.uuidString).setData(from: book)
            
            print("saved book to db :)")
        } catch {
            print("error saving book to db: \(error.localizedDescription)")
        }
    }

    // get book from db
    func fetchBookDetails(bookClubId: String) async throws {
        print("fetch book details")
        
        let db = Firestore.firestore()
        
        do {
            let snapshot = try? await db.collection("Book").document(bookClubId).getDocument()
            self.fetchedBook = try snapshot?.data(as: Book.self)
            
            print("fetched book from db :)")
        } catch {
            print("error fetching book from db: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    
    // delete??
//    func fetchOneBook(searchQuery: String) async throws {
//        // replace J4QUEAAAQBAJ with book id var
//        let bookUrlString = "https://www.googleapis.com/books/v1/volumes/J4QUEAAAQBAJ?key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"  // love hypothesis
//
//        guard let bookUrl = URL(string: bookUrlString) else {
//            fatalError("Invalid URL: \(bookUrlString)")
//        }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: bookUrl)
//            let decoder = JSONDecoder()
//            
//            let book = try decoder.decode(Book.self, from: data)
//            self.book = book
//            print("decoded one book")
//        } catch {
//            print("failed to load book data: \(error.localizedDescription)")
//        }
//    }
}
