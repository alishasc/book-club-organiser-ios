//
//  ChatLogView.swift
//  BookClub
//
//  Created by Alisha Carrington on 17/04/2025.
//

import SwiftUI

struct ChatLogView: View {
//    let chatUser: ChatUser?
    @State private var chatText: String = ""
    
    var body: some View {
        VStack {
            chatMessages
            chatBottomBar
        }
        .navigationTitle("User name")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var chatMessages: some View {
        ScrollView {
            ForEach(0..<10) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("FAKE MESSAGE FOR NOW")
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(.customBlue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack { Spacer() }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
    }
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundStyle(Color(.darkGray))
            TextField("Description", text: $chatText)
            Button {
                // action
            } label: {
                Text("Send")
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.customBlue)
            .cornerRadius(4)

        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        ChatLogView()
    }
}
