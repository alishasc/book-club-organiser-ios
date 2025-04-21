//
//  BookClubDetailsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct BookClubDetailsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var bookViewModel: BookViewModel
    var bookClub: BookClub
    var isModerator: Bool
    var isMember: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // cover image and title
                ZStack(alignment: .bottomLeading) {
                    // cover image
                    GeometryReader { geometry in
                        if let coverImage = bookClubViewModel.coverImages[bookClub.id] {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: 200)  // of image
                                .clipped()
                        }
                    }
                    .frame(height: 200)  // constrict GeometryReader height
                    
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
                    ClubDetailsMembersView(
                        moderatorName: bookClub.moderatorName,
                        moderatorPic: isModerator ? authViewModel.profilePic ?? UIImage() : bookClubViewModel.moderatorPic,
                        memberPics: bookClubViewModel.clubMemberPics
                    )
                    
                    ClubDetailsAboutView(description: bookClub.description)
                    
                    // current read
                    ClubDetailsCRView(bookClub: bookClub, currentRead: bookViewModel.currentRead, isModerator: isModerator)
                }
                .padding(.horizontal)
                
                // previously read books
                ClubDetailsPRView(isModerator: isModerator, booksRead: bookViewModel.booksRead)
                
                // upcoming events scheduled
                VStack {
                    ClubDetailsEventsView(bookClub: bookClub, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: isModerator)
                }
                
                Spacer()
            }
        }
        .ignoresSafeArea(SafeAreaRegions.all, edges: .top)
        .onAppear {
            Task {
                if bookClub.currentBookId != nil {
                    try await bookViewModel.fetchBook(bookId: bookClub.currentBookId ?? "")
                }
                try await bookClubViewModel.getModeratorAndMemberPics(bookClubId: bookClub.id, moderatorId: bookClub.moderatorId)
                try await bookViewModel.loadPRBooks(bookClub: bookClub)
            }
        }
        .onDisappear {
            bookViewModel.currentRead = nil
            bookClubViewModel.moderatorPic = UIImage()
            bookClubViewModel.clubMemberPics = [UIImage()]
        }
        .toolbar {
            if isModerator {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                }
            } else if !isMember {
                // change to else if condition - check if user has joined club already
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Join") {
                        Task {
                            try await bookClubViewModel.joinClub(bookClub: bookClub, currentUser: authViewModel.currentUser)
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    BookClubDetailsView()
//}
