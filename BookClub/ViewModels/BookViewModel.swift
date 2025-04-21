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
//    @Published var currentRead: Book?  // loaded from db
    // when search for books
    @Published var booksList: [Book] = []
    @Published var selectedBook: Book?
    
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
//    func saveBook(bookClubId: UUID, book: Book) async throws {
//        do {
//            let db = Firestore.firestore()
//            try db.collection("Book").document(book.id).setData(from: book)  // add to Book collection
//
//            // save as current read in BookClub collection
//            try await db.collection("BookClub").document(bookClubId.uuidString).setData([
//                "currentBookId": book.id
//            ], merge: true)
//        } catch {
//            print("error saving book to db: \(error.localizedDescription)")
//        }
//    }
    
    // fetches chosen book individually from API and saves to db
    func fetchOneBook(bookClubId: UUID, selectedBook: Book) async throws {
        let bookUrlString = "https://www.googleapis.com/books/v1/volumes/\(selectedBook.id)?key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"

        guard let bookUrl = URL(string: bookUrlString) else {
            fatalError("Invalid URL: \(bookUrlString)")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: bookUrl)
            let decoder = JSONDecoder()
            let book = try decoder.decode(Book.self, from: data)
            
            print("description: \(book.description)")
            print("genre: \(book.genre)")
            
            let db = Firestore.firestore()
            try db.collection("Book").document(book.id).setData(from: book)  // add to Book collection
            
            // save as current read in BookClub collection
            try await db.collection("BookClub").document(bookClubId.uuidString).setData([
                "currentBookId": book.id
            ], merge: true)
            
            print("success saving book")
        } catch {
            print("failed to save one book: \(error.localizedDescription)")
        }        
    }

    // get book from db - use the book's id
    func fetchBookDetails(bookId: String) async throws -> Book? {
        let db = Firestore.firestore()
        var currentRead: Book?
                
        do {
            let snapshot = try? await db.collection("Book").document(bookId).getDocument()
            currentRead = try snapshot?.data(as: Book.self)
        } catch {
            print("error fetching book from db: \(error.localizedDescription)")
        }
        
        return currentRead
    }
}
