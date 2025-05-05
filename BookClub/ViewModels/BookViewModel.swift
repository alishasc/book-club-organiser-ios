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
    let db = Firestore.firestore()

    @Published var currentRead: Book?  // loaded from api
    @Published var booksRead: [Book] = []  // previously read books
    // when search for books
    @Published var booksList: [Book] = []
    @Published var selectedBook: Book?
    @Published var bookBGColors: [String:UIColor] = [:]

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

            // save as current read in BookClub collection
            try await db.collection("BookClub").document(bookClubId.uuidString).setData([
                "currentBookId": book.id
            ], merge: true)
            
            // if a book was already being read - move to previously read
            if oldBookId != "" {
                // save old book to previously read - [booksRead]
                try await db.collection("BookClub").document(bookClubId.uuidString).updateData([
                    "booksRead": FieldValue.arrayUnion([oldBookId])
                ])
            }
            
            self.currentRead = book
            await self.loadImage(from: book)
        } catch {
            print("Failed to save book to db: \(error.localizedDescription)")
        }
    }
    
    func fetchBook(bookId: String) async throws {
        let bookUrlString = "https://www.googleapis.com/books/v1/volumes/\(bookId)?key=AIzaSyAQqgBd3cJn-lmTrbGmr--XMyfNnPprc8g"
        guard let bookUrl = URL(string: bookUrlString) else {
            fatalError("Invalid URL: \(bookUrlString)")
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: bookUrl)
            let decoder = JSONDecoder()
            self.currentRead = try decoder.decode(Book.self, from: data)
        } catch {
            print("Failed to load book: \(error.localizedDescription)")
        }
        
        if let book = self.currentRead {
            await self.loadImage(from: book)
        }
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
            for book in self.booksRead {
                await loadImage(from: book)
            }
        } catch {
            print("Error loading previously read books: \(error.localizedDescription)")
        }
    }
    
    func deleteBook(bookClubId: UUID, bookId: String) async throws {
        // delete previously read book
        do {
            try await db.collection("BookClub").document(bookClubId.uuidString).updateData([
                "booksRead": FieldValue.arrayRemove([bookId])
            ])
            
            // remove from booksRead array - update ui
            self.booksRead.removeAll(where: { $0.id == bookId })
        } catch {
            print("Error removing book from book club: \(error.localizedDescription)")
        }
    }
    
    // MARK: ref - https://medium.com/@nani.monish/swift-concurrency-async-await-download-images-8d91fe654982
    enum ImageError: Error {
        case invalidData
    }
    
    func loadImage(from book: Book) async {
        do {
            if let imageURL = URL(string: book.cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: "")) {
                let image = try await downloadImage(from: imageURL)
                self.bookBGColors[book.id] = image.dominantBackgroundColor()
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
    
    func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidData
        }
        return image
    }
}

// MARK: ref - https://medium.com/@shanukumar302/extracting-the-dominant-background-color-from-an-image-a-step-by-step-walkthrough-in-swift-e33694350b0d
extension UIImage {
    func dominantBackgroundColor() -> UIColor? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let cgImage = cgImage,
              let context = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else { return nil }
        
        context.draw(cgImage, in: rect)
   
        guard let data = context.data else { return nil }
        let pixels = data.assumingMemoryBound(to: UInt8.self)

        let samplePoints = [
            (0, 0),
            (Int(size.width) - 1, 0),
            (0, Int(size.height) - 1),
            (Int(size.width) - 1, Int(size.height) - 1)
        ]
        
        var colors: [UIColor] = []
        
        for (x, y) in samplePoints {
            let offset = 4 * (y * Int(size.width) + x)
            let color = UIColor(
                red: CGFloat(pixels[offset]) / 255.0,
                green: CGFloat(pixels[offset + 1]) / 255.0,
                blue: CGFloat(pixels[offset + 2]) / 255.0,
                alpha: CGFloat(pixels[offset + 3]) / 255.0
            )
            colors.append(color)
        }
        return findMostCommonColor(colors)
    }
    
    private func findMostCommonColor(_ colors: [UIColor]) -> UIColor {
        var colorCounts: [String: (UIColor, Int)] = [:]
        
        for color in colors {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let key = "\(Int(red * 255))-\(Int(green * 255))-\(Int(blue * 255))"
            
            if let (_, count) = colorCounts[key] {
                colorCounts[key] = (color, count + 1)
            } else {
                colorCounts[key] = (color, 1)
            }
        }
        
        let mostCommon = colorCounts.max(by: { $0.value.1 < $1.value.1 })
        return mostCommon?.value.0 ?? .white
    }
}
