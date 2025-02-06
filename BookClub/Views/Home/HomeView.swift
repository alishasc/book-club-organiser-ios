//
//  HomeView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // to get user info?
    @Binding var selectedTab: Int  // from NavBarView()

    var body: some View {
        VStack(spacing: 20) {
            // header
            HStack(spacing: 15) {
                Text("Hello \(authViewModel.currentUser?.name ?? "")")
                    .font(.largeTitle).bold()
                Spacer()
                // profile page
                NavigationLink(destination: UserProfileView(authViewModel: authViewModel)) {
                    Label("User Profile", systemImage: "person.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                        .foregroundStyle(.tint)
                }
                // notifications
                NavigationLink(destination: NotificationsView()) {
                    Label("Notifications", systemImage: "bell.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                        .foregroundStyle(.tint)
                }
            }
            
            // clubs
            VStack(spacing: 10) {
                HStack {
                    Text("Your Clubs")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("View all") {
                        selectedTab = 1  // clubs tab
                    }
                }
                // make row view
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ViewTemplates.bookClubRow(clubName: "Book Club Name")
                        ViewTemplates.bookClubRow(clubName: "Book Club Name")
                        ViewTemplates.bookClubRow(clubName: "Book Club Name")
                    }
                }
            }
            
            // events
            VStack(spacing: 10) {
                HStack {
                    Text("Your Upcoming Events")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("View all") {
                        selectedTab = 2  // events tab
                    }
                }
                // list view
                ScrollView(.vertical, showsIndicators: false) {
                    YourEventsListView(clubName: "Fantasy Book Club", clubRead: "Onyx Storm", location: "Waterstones Piccadilly", date: "Mon 01 Jan", time: "12:00", spacesLeft: 5)
                }
            }
        }
        .padding()
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
