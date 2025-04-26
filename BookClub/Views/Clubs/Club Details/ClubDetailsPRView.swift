//
//  ClubDetailsPRView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct ClubDetailsPRView: View {
    @EnvironmentObject var bookViewModel: BookViewModel
    var bookClub: BookClub
    var isModerator: Bool
    var booksRead: [Book]
    @State var showBookDetails: Bool = false
    @State var bookToView: Book?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Previously Read")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading)
            
            if !booksRead.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(booksRead.reversed()) { book in
                            Menu {
                                Button("View Book") {
                                    showBookDetails = true
                                    bookToView = book
                                }
                                if isModerator {
                                    Button("Delete") {
                                        // MARK: call function here
                                        Task {
                                            try await bookViewModel.deleteBook(bookClubId: bookClub.id, bookId: book.id)
                                        }
                                    }
                                }
                            } label: {
                                AsyncImage(url: URL(string: book.cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 142)
                                        .padding(15)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.customYellow.opacity(0.3))
                                        )
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ContentUnavailableView {
                    Label("This club hasn't read any books yet", systemImage: "books.vertical.fill")
                }
            }
        }
        .navigationDestination(isPresented: $showBookDetails) {
            if let bookToView {
                BookDetailsView(book: bookToView)
            }
        }
    }
}

//#Preview {
//    ClubDetailsPRView()
//}
