//
//  NavBarView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

// pages the navigation bar tabs are linked to

import SwiftUI

struct NavBarView: View {
    // when using nav links to switch to other navbar tabs on home screen
    @State private var selectedNavBarTab: Int = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedNavBarTab) {
                HomeView(selectedNavBarTab: $selectedNavBarTab)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                ClubsView(selectedNavBarTab: $selectedNavBarTab)
                    .tabItem {
                        Label("Clubs", systemImage: "book")
                    }
                    .tag(1)
                EventsView()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                    .tag(2)
                ExploreView()
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                    .tag(3)
                MessagesView(messageViewModel: MessageViewModel(chatUser: nil))
                    .tabItem {
                        Label("Messages", systemImage: "bubble")
                    }
                    .tag(4)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavBarView()
}
