//
//  ClubDetailsCRView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct ClubDetailsCRView: View {
    var bookClub: BookClub
    var currentRead: Book?
    var isModerator: Bool
    
    private var tidyDescription: String {
        if let currentRead {
            currentRead.description
                .replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression)
                .replacingOccurrences(of: "</p><p>", with: "\n\n", options: .regularExpression)
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        } else {
            "Loading..."
        }
    }
    
    // split genre string into array
    private var genresArr: [String] {
        if let currentRead {
            currentRead.genre.components(separatedBy: "/")
        } else {
            []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // title
                Text("Currently Reading")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                
                if isModerator {
                    // go to screen to search for book
                    NavigationLink(destination: BookSearchView(bookViewModel: BookViewModel(), bookClub: bookClub)) {
                        Text("New book")
                            .foregroundStyle(.customBlue)
                    }
                }
            }
            
            if let currentRead = currentRead {
                HStack(spacing: 15) {
                    // book cover
                    AsyncImage(url: URL(string: currentRead.cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: ""))) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 120)
                    
                    // book info
                    VStack(alignment: .leading) {
                        Text(currentRead.title)
                            .fontWeight(.semibold)
                        Text(currentRead.author)
                            .font(.subheadline)
                        Text(tidyDescription)
                            .font(.footnote)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        StaticTagView(tags: [TagViewItem(title: genresArr.first ?? "Unknown genre", isSelected: false)])
                    }
                    .foregroundStyle(.black)
                    
                    NavigationLink {
                        BookDetailsView(book: currentRead)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 24))
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.quaternaryHex.opacity(0.3))
                )
            } else {
                ContentUnavailableView {
                    Label("No book selected yet", systemImage: "book.closed.fill")
                }
            }
        }
    }
}

//#Preview {
//    ClubDetailsCRView(cover: "http://books.google.com/books/content?id=H-v8EAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api", title: "Onyx Storm", author: "Rebecca Yarros", genre: "Fantasy", synopsis: "After nearly eighteen months at Basgiath War College, Violet Sorrengail knows there's no more time for lessons. No more time for uncertainty. Because the battle has truly begun, and with enemies closing in from outside their walls and within their ranks, it's impossible to know who to trust.", isModerator: true)
//}
