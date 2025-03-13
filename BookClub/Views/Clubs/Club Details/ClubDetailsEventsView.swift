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

            // only show events for shown book club
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(eventViewModel.allEvents) { event in
                        if event.bookClubId == bookClub.id {
                            EventsRowView(bookClub: bookClub, coverImage: coverImage, event: event, isModerator: isModerator)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
    }
}

//#Preview {
//    ClubDetailsEventsView(bookClubId: "id", isModerator: true, isOnline: true)
//}
