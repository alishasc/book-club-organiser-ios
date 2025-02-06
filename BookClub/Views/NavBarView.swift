//
//  NavBarView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct NavBarView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
    // when using nav links to switch to other navbar tabs
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                ClubsView()
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
                MessagesView()
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
