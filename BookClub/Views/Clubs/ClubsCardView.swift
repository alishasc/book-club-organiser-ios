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
            Image(uiImage: coverImage)
                .resizable()
                .frame(height: 160)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
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
