//
//  NotificationsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack {
            ContentUnavailableView {
                Label("No Notifications", systemImage: "bell.slash.fill")
            }
        }
        .padding()
        .navigationTitle("Notifications")
    }
}

#Preview {
    NotificationsView()
}
