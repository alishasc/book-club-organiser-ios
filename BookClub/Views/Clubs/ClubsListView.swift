//
//  ClubsListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct ClubsListView: View {
    //    var coverImage...
    var clubName: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()  // replace with cover image
                .foregroundStyle(.quaternary)
                .frame(height: 150)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
            Text(clubName)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading, 15)
                .padding(.bottom, 10)
        }
    }
}

#Preview {
    ClubsListView(clubName: "Romance Book Club")
}
