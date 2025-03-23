//
//  ClubDetailsEventsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct ClubDetailsEventsView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    var bookClub: BookClub
    var coverImage: UIImage
    var isModerator: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // heading
            HStack {
                Text("Upcoming Events")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isModerator {
                    // go to screen to create new event
                    NavigationLink(destination: CreateEventView(meetingType: bookClub.meetingType, bookClubId: bookClub.id)) {
                        Text(Image(systemName: "plus"))
                            .font(.system(size: 24))
                            .foregroundStyle(.customBlue)
                    }
                }
            }
            .padding(.horizontal)

            // only show events for shown book club
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -20) {
                    ForEach(eventViewModel.allEvents) { event in
                        if event.bookClubId == bookClub.id {
                            EventsRowView(bookClub: bookClub, event: event, coverImage: coverImage, isModerator: isModerator)
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
            }
        }
    }
}

//#Preview {
//    ClubDetailsEventsView(bookClubId: "id", isModerator: true, isOnline: true)
//}
