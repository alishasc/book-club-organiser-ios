//
//  BookSearchView.swift
//  BookClub
//
//  Created by Alisha Carrington on 19/02/2025.
//

import SwiftUI

struct BookSearchView: View {
    @Environment(\.dismiss) private var dismiss  // change back button
    @StateObject var bookViewModel: BookViewModel
    @State private var searchQuery: String = ""
    @State private var isBookSelected: Bool = false
    
    var body: some View {
        VStack {
            // search bar/textfield
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 10)  // inside textfield
                TextField("Search for a book...", text: $searchQuery)
                    .padding([.top, .bottom, .trailing], 10)  // inside textfield
                    .onSubmit {
                        Task {
                            // call func to fetch book list from api with input
                            try await bookViewModel.fetchBooksList(searchQuery: searchQuery)
                        }
                    }
            }
            .background(.quinary)
            .cornerRadius(10)
            
            // list of search results
            if !bookViewModel.booksList.isEmpty {
                List() {
                    ForEach(bookViewModel.booksList) { book in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                            // highlight tapped option
                                .foregroundStyle(book.id == bookViewModel.selectedBook?.id ? .accent : .clear)
                            
                            HStack(spacing: 15) {
                                AsyncImage(url: URL(string: book.cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 80, height: 122)
                                
                                // book info
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                    Text(book.author)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Text(book.genre)
                                        .font(.subheadline)
                                        .padding(.bottom, 4)
                                        .lineLimit(1)
                                }
                                .foregroundStyle(book.id == bookViewModel.selectedBook?.id ? .white : .primary)
                            }
                            .padding(.horizontal)
                        }
                        .onTapGesture {
                            isBookSelected = true  // toggle foreground/background colour change
                            bookViewModel.selectedBook = book
                            
                            print(bookViewModel.selectedBook ?? "no book selected")
                        }
                        .onChange(of: searchQuery) {
                            // unselect book
                            bookViewModel.selectedBook = nil
                        }
                    }
                }
                .listStyle(.plain)
                .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20))  // extend list rows to edges of screen
                .scrollIndicators(.hidden)
            }
            
            // show message if haven't searched for anything
            if bookViewModel.booksList.isEmpty {
                ContentUnavailableView {
                    Label("No books", systemImage: "books.vertical.fill")
                } description: {
                    Text("Search for a book by title or author")
                }
            }
        }
        .padding()
        .ignoresSafeArea(SafeAreaRegions.all, edges: .bottom)  // extend list to bottom edge of screen
        .navigationTitle(Text("Choose a Book"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)  // use custom back button below instead
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                .disabled(bookViewModel.selectedBook == nil)
            }
        }
    }
}

#Preview {
    BookSearchView(bookViewModel: BookViewModel())
}
