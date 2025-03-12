//
//  BookSearchResultView.swift
//  BookClub
//
//  Created by Alisha Carrington on 12/03/2025.
//

import SwiftUI

struct BookSearchResultView: View {
    var book: Book
    var selectedBook: Book?
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
            // highlight tapped option
                .foregroundStyle(book.id == selectedBook?.id ? .accent : .clear)
            
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
                .foregroundStyle(book.id == selectedBook?.id ? .white : .primary)
            }
            .padding(.horizontal)
        }
    }
}

//#Preview {
//    BookSearchResultView()
//}
