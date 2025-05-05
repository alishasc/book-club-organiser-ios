//
//  HomeView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/04/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @Binding var selectedNavBarTab: Int  // from NavBarView()
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            header
            
            // if haven't joined or created a club
            if bookClubViewModel.joinedClubs.isEmpty && bookClubViewModel.createdClubs.isEmpty {
                Spacer()
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
                Spacer()
                Image("homePageBanner")
                    .resizable()
                    .scaledToFill()
                    .padding(.bottom, 6)
            } else {
                yourClubs
                yourEvents
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 15) {
            // only display first name if user added more than one
            Text("Hello \(authViewModel.currentUser?.name.components(separatedBy: " ").first ?? "")")
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
                    ForEach((bookClubViewModel.joinedClubs + bookClubViewModel.createdClubs).prefix(3).sorted(by: { $0.name.lowercased() < $1.name.lowercased() })) { club in
                        NavigationLink(destination: ClubHostView(bookClub: club, isModerator: club.moderatorId == authViewModel.currentUser?.id, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                            ViewTemplates.bookClubRow(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name, clubGenre: club.genre)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .scrollClipDisabled()
        }
    }
    private var yourEvents: some View {
        VStack(spacing: 10) {
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
            
            // if haven't joined or created any events
            if eventViewModel.joinedEvents.isEmpty && !eventViewModel.allEvents.contains(where: { $0.moderatorId == authViewModel.currentUser?.id }) {
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
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(eventViewModel.filteredUpcomingEvents(selectedFilter: 0, bookClubViewModel: bookClubViewModel, selectedClubName: nil).prefix(3), id: \.event.id) { event, bookClub in
                        EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorId == authViewModel.currentUser?.id)
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
