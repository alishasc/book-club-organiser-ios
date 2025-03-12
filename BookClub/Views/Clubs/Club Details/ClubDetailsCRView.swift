//
//  ClubDetailsCRView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

// this will be filled with book API information

struct ClubDetailsCRView: View {
    var cover: String
    var title: String
    var author: String
    var genre: String
    var synopsis: String
    var isModerator: Bool
    
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
                    NavigationLink(destination: BookSearchView(bookViewModel: BookViewModel())) {
                        Text("New book")
                            .foregroundStyle(.customBlue)
                    }
                }
            }
            
            //                NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
            HStack(spacing: 15) {
                // book cover
                AsyncImage(url: URL(string: cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: ""))) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 120)

                // book info
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.semibold)
                    Text(author)
                        .font(.subheadline)
                    Text(genre)
                        .font(.subheadline)
                        .padding(.bottom, 4)
                    Text(synopsis)
                        .font(.footnote)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(.black)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 24))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.quaternaryHex.opacity(0.3))
            )
            //                }
        }
    }
}

#Preview {
    ClubDetailsCRView(cover: "http://books.google.com/books/content?id=H-v8EAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api", title: "Onyx Storm", author: "Rebecca Yarros", genre: "Fantasy", synopsis: "After nearly eighteen months at Basgiath War College, Violet Sorrengail knows there's no more time for lessons. No more time for uncertainty. Because the battle has truly begun, and with enemies closing in from outside their walls and within their ranks, it's impossible to know who to trust.", isModerator: true)
}
