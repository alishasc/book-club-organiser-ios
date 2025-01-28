//
//  NavBarView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct NavBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    // when using buttons to switch to other tabs
    @State private var selectedTab: Int = 0

    var body: some View {
        // if just signed up - go to onboarding
        if authViewModel.isNewUser == true {
//            OnboardingGenresView(onboardingViewModel: OnboardingViewModel())
        // if already logged in go to home page
        } else if authViewModel.userSession != nil && authViewModel.isNewUser == false {
            navBar
        } else {
            LoginView()
        }
    }
    
    var navBar: some View {
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
