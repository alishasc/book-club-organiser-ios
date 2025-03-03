//
//  ContentView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

// makes sure correct screen is showing when application opens

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        // go to onboarding if just signed up
        if authViewModel.isNewUser == true {
            OnboardingGenresView(onboardingViewModel: OnboardingViewModel())
        } else if authViewModel.userSession != nil && authViewModel.isNewUser == false {
            // go to home page if already logged in
            NavBarView()
        } else {
            LoginView()
        }        
    }
}

#Preview {
    ContentView()
}
