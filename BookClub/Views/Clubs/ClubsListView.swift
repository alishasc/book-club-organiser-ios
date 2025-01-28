//
//  ClubsListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct ClubsListView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .foregroundStyle(.quaternary)
                .frame(height: 150)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
            Text("Book Club Name")
                .padding([.leading, .bottom], 10)
        }
    }
}

#Preview {
    ClubsListView()
}
