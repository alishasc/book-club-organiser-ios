//
//  BookDetailsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 16/04/2025.
//

import SwiftUI

struct BookDetailsView: View {
    var book: Book
        
    private var tidyDescription: String {
        book.description
            .replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression)  // fix line breaks
            .replacingOccurrences(of: "</p><p>", with: "\n\n", options: .regularExpression)
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)  // remove remaining html tags
    }
    
    // split genre string into array
    private var genresArr: [String] {
        book.genre.components(separatedBy: "/")
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                // book cover
                AsyncImage(url: URL(string: book.cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: ""))) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 120, height: 160)
                
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(book.author)
                    .font(.subheadline)
                
                Text("Genre:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                StaticTagView(tags: genresArr.map { TagViewItem(title: $0, isSelected: false) })
                
                Text("Description:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(tidyDescription)
            }
        }
        .padding()
    }
}

//#Preview {
//    BookDetailsView()
//}
