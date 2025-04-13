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
    @EnvironmentObject var authViewModel: AuthViewModel  // to get user info
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @Binding var selectedNavBarTab: Int  // from NavBarView()
    
    var body: some View {
        VStack(spacing: 20) {
            // header
            HStack(spacing: 15) {
                Text("Hello \(authViewModel.currentUser?.name ?? "")")
                    .font(.largeTitle).bold()
                Spacer()
                // profile page
                NavigationLink(destination: ProfileView(bookClubViewModel: bookClubViewModel, authViewModel: authViewModel)) {
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
            .padding([.top, .horizontal])
            
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
                    .foregroundStyle(.customBlue)
                }
                .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(bookClubViewModel.joinedClubs) { club in
                            NavigationLink(destination: BookClubDetailsView(bookClub: club, isModerator: club.moderatorName == authViewModel.currentUser?.name, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                                ViewTemplates.bookClubRow(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name)
                            }
                            .padding(.vertical, 15)  // to see shadows
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, -15)  // reverse padding to see shadows
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
                    .foregroundStyle(.customBlue)
                }
                
                // scrollview of events the user is attending
                ScrollView(.vertical, showsIndicators: false) {
                        ForEach(eventViewModel.joinedEvents) { event in
                            if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
                                EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorName == authViewModel.currentUser?.name)
                                    .padding([.horizontal, .top], 10)  // to show shadowing
                                    .padding(.bottom, -2)
                            }
                        }
                }
                .padding([.horizontal, .top], -10)  // reduce size of padding from showing shadows
            }
            .padding([.horizontal, .bottom])
        }
    }
}

#Preview {
    HomeView(selectedNavBarTab: .constant(0))
        .environmentObject(AuthViewModel())
}
