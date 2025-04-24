//
//  HomeView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

import UIKit

//extension UIScrollView {
//  open override var clipsToBounds: Bool {
//    get { false }
//    set { }
//  }
//}

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @Binding var selectedNavBarTab: Int  // from NavBarView()
    
    var body: some View {
        VStack(spacing: 20) {
            header
            yourClubs
            yourEvents
            
            if bookClubViewModel.joinedClubs.isEmpty && eventViewModel.joinedEvents.isEmpty {
                Spacer()
                Image("homePageBanner")
                    .resizable()
                    .padding(.bottom, 6)
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 15) {
            Text("Hello \(authViewModel.currentUser?.name ?? "")")
                .font(.largeTitle).bold()
            Spacer()
            // profile page
            if let profile = authViewModel.currentUser,
               let profilePic = authViewModel.profilePic {
                NavigationLink(destination: ProfileHostView(profile: profile, profilePic: profilePic, joinedClubs: bookClubViewModel.joinedClubs.count, createdClubs: bookClubViewModel.createdClubs.count)) {
                    Label("User Profile", systemImage: "person.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                        .foregroundStyle(.accent)
                }
            }
            // notifications
            NavigationLink(destination: NotificationsView()) {
                Label("Notifications", systemImage: "bell.fill")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 24))
                    .foregroundStyle(.accent)
            }
        }
        .padding([.top, .horizontal])
    }
    private var yourClubs: some View {
        VStack(spacing: 10) {
            // haven't joined any clubs yet
            if bookClubViewModel.joinedClubs.isEmpty {
                ContentUnavailableView {
                    Label("Find a book club to join", systemImage: "books.vertical.fill")
                } description: {
                    Button {
                        selectedNavBarTab = 3  // clubs tab
                    } label: {
                        HStack {
                            Text("Explore Clubs")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                }
            } else {
                VStack(spacing: 10) {
                    HStack {
                        Text("Your Clubs")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("View all") {
                            selectedNavBarTab = 1  // clubs tab
                        }
                        .foregroundStyle(.customBlue)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // show both joined and created clubs (max 3)
                            ForEach((bookClubViewModel.joinedClubs + bookClubViewModel.createdClubs).prefix(3).sorted { $0.name < $1.name }) { club in
                                NavigationLink(destination: BookClubDetailsView(bookClub: club, isModerator: club.moderatorName == authViewModel.currentUser?.name, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                                    ViewTemplates.bookClubRow(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollClipDisabled()
                }
            }
        }
    }
    private var yourEvents: some View {
        VStack(spacing: 10) {
            // have joined clubs or events
            if !bookClubViewModel.joinedClubs.isEmpty || !eventViewModel.joinedEvents.isEmpty {
                HStack {
                    Text("Your Upcoming Events")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("View all") {
                        selectedNavBarTab = 2  // events tab
                    }
                    .foregroundStyle(.customBlue)
                }
            }

            // joined clubs but no events
            if !bookClubViewModel.joinedClubs.isEmpty && eventViewModel.joinedEvents.isEmpty {
                ContentUnavailableView {
                    Label("Find events to join", systemImage: "calendar")
                } description: {
                    Button {
                        selectedNavBarTab = 2  // events tab
                    } label: {
                        HStack {
                            Text("Events")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                }
            }
            // have joined both clubs and events
            else if !bookClubViewModel.joinedClubs.isEmpty && !eventViewModel.joinedEvents.isEmpty {
                // scrollview of events the user is attending/created
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(eventViewModel.filteredUpcomingEvents(selectedFilter: 0, bookClubViewModel: bookClubViewModel, selectedClubName: nil).prefix(3), id: \.event.id) { event, bookClub in
                        EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorName == authViewModel.currentUser?.name)
                            .padding(.bottom, 8)
                    }
                }
                .scrollClipDisabled()
            }
        }
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    HomeView(selectedNavBarTab: .constant(0))
        .environmentObject(AuthViewModel())
        .environmentObject(BookClubViewModel())
        .environmentObject(EventViewModel())
}
