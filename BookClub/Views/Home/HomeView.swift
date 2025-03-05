//
//  HomeView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // to get user info
    @Binding var selectedNavBarTab: Int  // from NavBarView()

    var body: some View {
        VStack(spacing: 20) {
            // header
            HStack(spacing: 15) {
                Text("Hello \(authViewModel.currentUser?.name ?? "")")
                    .font(.largeTitle).bold()
                Spacer()
                // profile page
                NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                    Label("User Profile", systemImage: "person.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                        .foregroundStyle(.accent)
                }
                // notifications
                NavigationLink(destination: NotificationsView()) {
                    Label("Notifications", systemImage: "bell.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                        .foregroundStyle(.accent)
                }
            }
            
            // your clubs
            VStack(spacing: 10) {
                HStack {
                    Text("Your Clubs")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("View all") {
                        selectedNavBarTab = 1  // clubs tab
                    }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ViewTemplates.bookClubRow(clubName: "Book Club Name")
                        ViewTemplates.bookClubRow(clubName: "Book Club Name")
                        ViewTemplates.bookClubRow(clubName: "Book Club Name")
                    }
                }
            }
            
            // upcoming events
            VStack(spacing: 10) {
                HStack {
                    Text("Your Upcoming Events")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("View all") {
                        selectedNavBarTab = 2  // events tab
                    }
                }
                // scrollview of events the user is ATTENDING - replace spacer
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    HomeView(selectedNavBarTab: .constant(0))
        .environmentObject(AuthViewModel())
}
