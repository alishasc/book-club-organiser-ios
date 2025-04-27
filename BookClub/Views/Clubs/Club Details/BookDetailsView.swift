//
//  BookDetailsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 16/04/2025.
//

import SwiftUI

struct BookDetailsView: View {
    @EnvironmentObject var bookViewModel: BookViewModel
    @Environment(\.dismiss) var dismiss
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
            VStack {
                ZStack(alignment: .bottom) {
                    // background
                    GeometryReader { geometry in
                        Rectangle()
                            .frame(width: geometry.size.width, height: 300)
                            .foregroundStyle(Color(bookViewModel.bookBGColors[book.id] ?? UIColor.quaternaryHex)).opacity(0.3)
                    }
                    .frame(height: 300)
                    
                    // book cover image
                    AsyncImage(url: URL(string: book.cover.replacingOccurrences(of: "http", with: "https").replacingOccurrences(of: "&edge=curl", with: ""))) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 120, height: 185)
                    .padding(.bottom, 20)
                }
                
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.medium)
                    Text(book.author)
                    
                    StaticTagView(tags: genresArr.map { TagViewItem(title: $0, isSelected: false) })
                    
                    Text("Description:")
                        .fontWeight(.medium)
                    Text(tidyDescription)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.quaternaryHex.opacity(0.6))
                        )
                }
                .padding([.horizontal, .bottom])
            }
        } // scrollview
        .ignoresSafeArea(SafeAreaRegions.all, edges: .top)
        .navigationTitle(book.title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
            }
        }
    }
}

//#Preview {
//    BookDetailsView()
//}
