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
    @Environment(\.dismiss) var dismiss
    var bookClub: BookClub
    var isModerator: Bool
    var isMember: Bool
    
    @State private var isMemberState = false  // re-render UI
    @State private var showAlert = false  // alert to leave club
    
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
                        moderatorInfo: bookClubViewModel.moderatorInfo,
                        memberPics: bookClubViewModel.clubMemberPics
                    )
                    
                    ClubDetailsAboutView(description: bookClub.description)
                    
                    // current read
                    ClubDetailsCRView(bookClub: bookClub, currentRead: bookViewModel.currentRead, isModerator: isModerator)
                }
                .padding(.horizontal)
                
                // previously read books
                ClubDetailsPRView(bookClub: bookClub, isModerator: isModerator, booksRead: bookViewModel.booksRead)
                
                // upcoming events scheduled
                VStack {
                    ClubDetailsEventsView(bookClub: bookClub, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: isModerator)
                }
                
                // alert
                if isMemberState {
                    Button {
                        showAlert = true
                    } label: {
                        Text("Leave Club")
                            .foregroundStyle(.red)
                            .fontWeight(.medium)
                    }
                    .alert("Are you sure?", isPresented: $showAlert) {
                        Button("Leave \(bookClub.name)", role: .destructive) {
                            Task {
                                try await bookClubViewModel.leaveClub(bookClubId: bookClub.id, eventViewModel: eventViewModel)
                                bookClubViewModel.clubMemberPics.removeAll(where: { $0 == authViewModel.profilePic })
                            }
                            isMemberState = false
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
            }
        }
        .ignoresSafeArea(SafeAreaRegions.all, edges: .top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                if bookClub.currentBookId != nil {
                    try await bookViewModel.fetchBook(bookId: bookClub.currentBookId ?? "")
                }
                
                try await bookClubViewModel.getModeratorAndMemberPics(bookClubId: bookClub.id, moderatorId: bookClub.moderatorId, authViewModel: authViewModel)
                
                if bookViewModel.booksRead.isEmpty {
                    try await bookViewModel.loadPRBooks(bookClub: bookClub)
                }
            }
            
            isMemberState = isMember
        }
        .toolbar {
            if isModerator {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .font(.subheadline)
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                }
            } else if !isMemberState {
                // change to else if condition - check if user has joined club already
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Join") {
                        Task {
                            try await bookClubViewModel.joinClub(bookClub: bookClub, currentUser: authViewModel.currentUser)
                            bookClubViewModel.clubMemberPics.append(authViewModel.profilePic ?? UIImage())
                        }
                        isMemberState = true
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    bookViewModel.currentRead = nil
                    bookViewModel.booksRead.removeAll()
                    bookClubViewModel.moderatorInfo = [:]
                    bookClubViewModel.clubMemberPics = [UIImage()]
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
            }
        }
    }
}

//#Preview {
//    BookClubDetailsView()
//}
