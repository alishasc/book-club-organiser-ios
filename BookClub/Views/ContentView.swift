//
//  ContentView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isNewUser == true {
            // go to onboarding if just signed up
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

