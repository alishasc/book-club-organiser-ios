//
//  testBook.swift
//  BookClub
//
//  Created by Alisha Carrington on 12/03/2025.
//

import SwiftUI

struct testBook: View {
    @StateObject var viewModel: BookViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 10) {
                if let book = viewModel.fetchedBook {
                    let description = book.description.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression)  // fix line breaks
                    let description2 = description.replacingOccurrences(of: "</p><p>", with: "\n\n", options: .regularExpression)
                    let description3 = description2.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)  // remove other html tags
                    
                    Text("id: \(book.id)")
                    Text("title: \(book.title)")
                    Text("author: \(book.author)")
                    Text(description3)
                    Text("page count: \(book.pageCount)")
                    Text("genre: \(book.genre)")

                    AsyncImage(url: URL(string: book.cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: ""))) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 240)
                }
            }
        }
        .onAppear {
            Task {
                try await viewModel.fetchBookDetails(bookId: "E-OLEAAAQBAJ")
            }
        }
    }
}

#Preview {
    testBook(viewModel: BookViewModel())
}
