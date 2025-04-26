//
//  BookViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 19/02/2025.
//

import Foundation
import FirebaseFirestore
import UIKit

@MainActor
class BookViewModel: ObservableObject {
    @Published var currentRead: Book?  // loaded from api
    @Published var booksRead: [Book] = []  // previously read books
    // when search for books
    @Published var booksList: [Book] = []
    @Published var selectedBook: Book?
    
    
//    @Published var currentReadImage: UIImage?

    
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
        } catch {
            print("failed to load book data: \(error.localizedDescription)")
        }
    }
    
    // fetches chosen book individually from API and saves to db
    func fetchBookFromAPI(bookClubId: UUID, selectedBook: Book, oldBookId: String) async throws {
        let bookUrlString = "https://www.googleapis.com/books/v1/volumes/\(selectedBook.id)?key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"
        guard let bookUrl = URL(string: bookUrlString) else {
            fatalError("Invalid URL: \(bookUrlString)")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: bookUrl)
            let decoder = JSONDecoder()
            let book = try decoder.decode(Book.self, from: data)
            
            let db = Firestore.firestore()

            // save as current read in BookClub collection
            try await db.collection("BookClub").document(bookClubId.uuidString).setData([
                "currentBookId": book.id
            ], merge: true)
            
            self.currentRead = book
            
            // save old book to previously read - [booksRead]
            try await db.collection("BookClub").document(bookClubId.uuidString).updateData([
                "booksRead": FieldValue.arrayUnion([oldBookId])
            ])
        } catch {
            print("failed to save book to db: \(error.localizedDescription)")
        }
    }
    
    func fetchBook(bookId: String) async throws {
        let bookUrlString = "https://www.googleapis.com/books/v1/volumes/\(bookId)?key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"
        guard let bookUrl = URL(string: bookUrlString) else {
            fatalError("Invalid URL: \(bookUrlString)")
        }
        var book: Book?
        
        do {
            let (data, _) = try await URLSession.shared.data(from: bookUrl)
            let decoder = JSONDecoder()
            book = try decoder.decode(Book.self, from: data)
        } catch {
            print("failed to load book: \(error.localizedDescription)")
        }
        
        self.currentRead = book
    }
    
    func loadPRBooks(bookClub: BookClub) async throws {
        self.booksRead.removeAll()
        var downloadedBooks: [Book] = []
        
        do {
            // loop books read array
            if let books = bookClub.booksRead {
                if !books.isEmpty {
                    for bookId in books {
                        let bookUrlString = "https://www.googleapis.com/books/v1/volumes/\(bookId)?key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"
                        guard let bookUrl = URL(string: bookUrlString) else {
                            fatalError("Invalid URL: \(bookUrlString)")
                        }
                        
                        let (data, _) = try await URLSession.shared.data(from: bookUrl)
                        let decoder = JSONDecoder()
                        let book = try decoder.decode(Book.self, from: data)
                        downloadedBooks.append(book)
                    }
                }
            }
            self.booksRead = downloadedBooks
        } catch {
            print("Error loading previously read books: \(error.localizedDescription)")
        }
    }
    
    func deleteBook(bookId: String) async throws {
        // delete previously read book
        // remove from PR book array in BookClub collection
    }
    
    
    
    
    
    
    
    // code ref: https://medium.com/@nani.monish/swift-concurrency-async-await-download-images-8d91fe654982
//    enum ImageError: Error {
//        case invalidData
//    }
//
//    func loadImage(from bookId: String) async {
//        do {
//            let imageURL = URL(string: "https://books.google.com/books/publisher/content?id=J4QUEAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE73Lq1ARR_mM_y-5ZI44P3udrPPUrvugON9M8R2-OYlD5mTahJMeCNHEXwo6-gD82VUpEbUEgZ3q3bRsXoZ_Px1Bp4SyUOU5aTM1Bow1kHY_SPIbbfqDM_jegPlDFvgvEdm6576u&source=gbs_api")!
//            let image = try await downloadImage(from: imageURL)
//            self.currentReadImage = image
//            // Display or use the downloaded image
//        } catch {
//            // Handle the error
//            print("error loading image: \(error.localizedDescription)")
//        }
//    }
//    
//    func downloadImage(from url: URL) async throws -> UIImage {
//        let (data, _) = try await URLSession.shared.data(from: url)
//        guard let image = UIImage(data: data) else {
//            throw ImageError.invalidData
//        }
//        return image
//    }
}

