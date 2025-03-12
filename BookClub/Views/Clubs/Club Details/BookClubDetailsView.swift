//
//  BookClubDetailsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct BookClubDetailsView: View {
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var photosPickerViewModel: PhotosPickerViewModel
    var bookClub: BookClub
    var moderatorName: String
    var isModerator: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // cover image and title
                ZStack(alignment: .bottomLeading) {
                    // cover image
                    if let coverImage = bookClubViewModel.coverImages[bookClub.id] {
                        GeometryReader { geometry in
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: 200)  // of image
                        }
                        .frame(height: 200)  // constrict GeometryReader height
                    } else {
                        Rectangle()
                            .frame(height: 200)
                            .foregroundStyle(.customGreen)
                    }
                    
                    // title
                    Text(bookClub.name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding([.leading, .bottom], 15)
                }
                
                // moderator/member info and current read
                VStack(alignment: .leading, spacing: 20) {
                    // moderator and members info
                    ClubDetailsMembersView(moderatorName: moderatorName)
                    
                    ClubDetailsAboutView(description: bookClub.description)
                    
                    // get book details for this!
                    ClubDetailsCRView(cover: "http://books.google.com/books/content?id=H-v8EAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api", title: "Onyx Storm", author: "Rebecca Yarros", genre: "Fantasy", synopsis: "After nearly eighteen months at Basgiath War College, Violet Sorrengail knows there's no more time for lessons. No more time for uncertainty. Because the battle has truly begun, and with enemies closing in from outside their walls and within their ranks, it's impossible to know who to trust.", isModerator: isModerator)
                }
                .padding(.horizontal)
                
                // previously read books
                ClubDetailsPRView()
                
                // upcoming events scheduled
                VStack {
                    ClubDetailsEventsView(eventViewModel: eventViewModel, bookClub: bookClub, isModerator: isModerator)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .ignoresSafeArea(SafeAreaRegions.all, edges: .top)
        .onAppear {
            Task {
                try await eventViewModel.fetchEvents()  // get latest events
            }
        }
    }
}

//#Preview {
//    BookClubDetailsView()
//}
