//
//  ClubDetailsEventsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct ClubDetailsEventsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming Events")
                .font(.title3)
                .fontWeight(.semibold)
            
//            ScrollView(.horizontal, showsIndicators: false) {
                YourEventsListView(clubName: "Fantasy Book Club", clubRead: "Onyx Storm", location: "Online", date: "Mon 01 Jan", time: "12:00", spacesLeft: 5)
//            }
        }
    }
}

#Preview {
    ClubDetailsEventsView()
}
