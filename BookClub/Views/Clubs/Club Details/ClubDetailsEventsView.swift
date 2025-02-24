//
//  ClubDetailsEventsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct ClubDetailsEventsView: View {
    var isModerator: Bool
    var isOnline: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Upcoming Events")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isModerator {
                    // go to screen to create new event
                    NavigationLink(destination: CreateEventView(isOnline: isOnline)) {
                        Text(Image(systemName: "plus"))
                    }
                }
            }
            
//            ScrollView(.horizontal, showsIndicators: false) {
                YourEventsListView(clubName: "Fantasy Book Club", clubRead: "Onyx Storm", location: "Online", date: "Mon 01 Jan", time: "12:00", spacesLeft: 5)
//            }
        }
    }
}

#Preview {
    ClubDetailsEventsView(isModerator: true, isOnline: true)
}
