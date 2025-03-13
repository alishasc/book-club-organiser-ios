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
    @EnvironmentObject var bookViewModel: BookViewModel
    @State private var currentRead: Book?
    var bookClub: BookClub
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
                                .clipped()
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
                    ClubDetailsMembersView(moderatorName: bookClub.moderatorName)
                    
                    ClubDetailsAboutView(description: bookClub.description)
                    
                    // current read
                    ClubDetailsCRView(bookClub: bookClub, currentRead: currentRead, isModerator: isModerator)
                }
                .padding(.horizontal)
                
                // previously read books
                ClubDetailsPRView()
                
                // upcoming events scheduled
                VStack {
                    ClubDetailsEventsView(bookClub: bookClub, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: isModerator)
                }
                .padding([.horizontal, .bottom])
                
                Spacer()
                
                Button("Delete") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
            }
        }
        .ignoresSafeArea(SafeAreaRegions.all, edges: .top)
        .onAppear {
            Task {
                try await eventViewModel.fetchEvents()  // get latest events
                
                if bookClub.currentBookId != nil {
                    self.currentRead = try await bookViewModel.fetchBookDetails(bookId: bookClub.currentBookId ?? "")  // to show current read info
                }
            }
        }
        .toolbar {
            if isModerator {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .foregroundStyle(.customPink)
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Join") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .foregroundStyle(.customPink)
                }
            }
        }
    }
}

//#Preview {
//    BookClubDetailsView()
//}
