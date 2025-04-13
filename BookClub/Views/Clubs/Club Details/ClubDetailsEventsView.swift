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
    
    // ref: https://stackoverflow.com/questions/68143240/tabview-dot-index-color-does-not-change
    init(bookClub: BookClub, coverImage: UIImage, isModerator: Bool) {
        UIPageControl.appearance().currentPageIndicatorTintColor = .accent
        self.bookClub = bookClub
        self.coverImage = coverImage
        self.isModerator = isModerator
    }

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

            TabView {
                ForEach(eventViewModel.allEvents) { event in
                    if event.bookClubId == bookClub.id {
                        EventsRowView(bookClub: bookClub, event: event, coverImage: coverImage, isModerator: isModerator)
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .padding(.top, 10)
                            .padding(.bottom, 50)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 160)
            .padding(.top, -10)
        }
    }
}

//#Preview {
//    ClubDetailsEventsView(bookClubId: "id", isModerator: true, isOnline: true)
//}
