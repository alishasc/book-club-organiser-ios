//
//  BookViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 19/02/2025.
//

import Foundation

@MainActor
class BookViewModel: ObservableObject {
    @Published var book: Book?  // when search for specific volume by id - get one
    @Published var booksList: [Book] = []  // get list of books
    @Published var selectedBook: Book?

    func fetchOneBook(searchQuery: String) async throws {
        let bookUrlString = "https://www.googleapis.com/books/v1/volumes/J4QUEAAAQBAJ?key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"  // love hypothesis

        guard let bookUrl = URL(string: bookUrlString) else {
            fatalError("Invalid URL: \(bookUrlString)")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: bookUrl)
            let decoder = JSONDecoder()
            
            let book = try decoder.decode(Book.self, from: data)
            self.book = book
            print("decoded one book")
        } catch {
            print("failed to load book data: \(error.localizedDescription)")
        }
    }
    
    func fetchBooksList(searchQuery: String) async throws {
//        let bookUrlString = "https://www.googleapis.com/books/v1/volumes?q=\(searchQuery)&maxResults=15&langRestrict=\("en")&key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"
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
}
