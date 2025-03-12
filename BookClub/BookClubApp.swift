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
    @StateObject var bookClubViewModel = BookClubViewModel()
    @StateObject var eventViewModel = EventViewModel()
    @StateObject var photosPickerViewModel = PhotosPickerViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(bookClubViewModel)
                .environmentObject(eventViewModel)
                .environmentObject(photosPickerViewModel)
        }
    }
}
