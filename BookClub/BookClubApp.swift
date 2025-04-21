//
//  BookClubApp.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI
import FirebaseCore

@main
struct BookClubApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    @StateObject var bookClubViewModel = BookClubViewModel()
    @StateObject var eventViewModel = EventViewModel()
    @StateObject var photosPickerViewModel = PhotosPickerViewModel()
    @StateObject var bookViewModel = BookViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(onboardingViewModel)
                .environmentObject(bookClubViewModel)
                .environmentObject(eventViewModel)
                .environmentObject(photosPickerViewModel)
                .environmentObject(bookViewModel)
        }
    }
}
