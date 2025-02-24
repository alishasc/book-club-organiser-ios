//
//  BookClubDetailsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct BookClubDetailsView: View {
    var bookClub: BookClub
    var moderatorName: String
    var isModerator: Bool
    var isOnline: Bool  // is book club online?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // cover image and title
                ZStack(alignment: .bottomLeading) {
                    // cover image
                    Rectangle()
                        .frame(height: 200)
                        .foregroundStyle(.customGreen)
                        .background(
                            Image("PATH_TO_IMAGE")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        )
                    // title
                    Text(bookClub.name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding([.leading, .bottom], 15)
                }

                VStack(alignment: .leading, spacing: 20) {
                    // moderator and members info
                    ClubDetailsMembersView(moderatorName: moderatorName)
                    
                    ClubDetailsAboutView(description: bookClub.description)
                    
                    // get book details for this!
                    ClubDetailsCRView(title: "Onyx Storm", author: "Rebecca Yarros", genre: "Fantasy", synopsis: "After nearly eighteen months at Basgiath War College, Violet Sorrengail knows there's no more time for lessons. No more time for uncertainty. Because the battle has truly begun, and with enemies closing in from outside their walls and within their ranks, it's impossible to know who to trust.", isModerator: isModerator)
                }
                .padding(.horizontal)
                    
                // previously read books
                ClubDetailsPRView()
                    
                // upcoming events scheduled
                VStack {
                    ClubDetailsEventsView(isModerator: isModerator, isOnline: isOnline)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .ignoresSafeArea(SafeAreaRegions.all, edges: .top)
    }
}

#Preview {
    BookClubDetailsView(bookClub: BookClub(name: "romance", moderatorId: "123", description: "we read romance here!", genre: "romance", meetingType: "online", isPublic: true, creationDate: Date(timeIntervalSinceNow: 0)), moderatorName: "moderator name", isModerator: true, isOnline: true)
}
