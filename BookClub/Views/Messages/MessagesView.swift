//
//  MessagesView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct MessagesView: View {
    var body: some View {
        VStack {
            // header
            HStack {
                Text("Messages")
                    .font(.largeTitle).bold()
                Spacer()
                // new message button
                NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
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
    }
}

#Preview {
    MessagesView()
}
