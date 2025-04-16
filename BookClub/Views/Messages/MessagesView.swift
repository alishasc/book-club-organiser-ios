//
//  MessagesView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    
    var body: some View {
        VStack {
            // header
            HStack {
                Text("Messages")
                    .font(.largeTitle).bold()
                Spacer()
                // new message button
                NavigationLink(destination: UserListView(users: bookClubViewModel.messageUsers, profilePics: bookClubViewModel.memberPics)) {
                    Label("New message", systemImage: "square.and.pencil")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 24))
                }
            }
            
            Spacer()
            
            ContentUnavailableView {
                Label("No Messages", systemImage: "bubble.fill")
            } description: {
                Text("New messages you receive will appear here.")
            }
        }
        .padding()
        .onAppear {
            Task {
                try await bookClubViewModel.getMessageUserList()
            }
        }
    }
}

#Preview {
    MessagesView()
}
