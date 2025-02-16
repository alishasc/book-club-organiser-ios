//
//  ClubDetailsCRView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

// this will be filled with book API information

struct ClubDetailsCRView: View {
//    var cover: Image
    var title: String
    var author: String
    var genre: String
    var synopsis: String
    
    var body: some View {
//        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Currently Reading")
                    .font(.title3)
                    .fontWeight(.semibold)
                
//                NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                    HStack(spacing: 15) {
                        // book cover
                        Image(/*@START_MENU_TOKEN@*/"Image Name"/*@END_MENU_TOKEN@*/)  // or async image?
                            .resizable()
                            .frame(width: 80, height: 120)
                            .background(.customPink)
                        
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
//        }
    }
}

#Preview {
    ClubDetailsCRView(title: "Onyx Storm", author: "Rebecca Yarros", genre: "Fantasy", synopsis: "After nearly eighteen months at Basgiath War College, Violet Sorrengail knows there's no more time for lessons. No more time for uncertainty. Because the battle has truly begun, and with enemies closing in from outside their walls and within their ranks, it's impossible to know who to trust.")
}
