//
//  ClubsListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct ClubsCardView: View {
    var coverImage: UIImage
    var clubName: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geometry in
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: 160)  // of image
                    .cornerRadius(10)
                    .clipped()
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)  // drop shadow
            }
            .frame(height: 160)  // constrict GeometryReader height
            
            Text(clubName)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding([.leading, .bottom], 15)
        }
    }
}

#Preview {
    ClubsCardView(coverImage: UIImage(), clubName: "Romance Book Club")
}
