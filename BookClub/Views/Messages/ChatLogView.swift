//
//  ChatLogView.swift
//  BookClub
//
//  Created by Alisha Carrington on 17/04/2025.
//

import SwiftUI
import FirebaseAuth

struct ChatLogView: View {
    @ObservedObject var messageViewModel: MessageViewModel
    let chatUser: BookClubMembers?  // recipient of message
    
    init(chatUser: BookClubMembers?) {
        self.chatUser = chatUser
        self.messageViewModel = .init(chatUser: chatUser)
    }
    
    var body: some View {
        VStack {
            chatMessages
            chatBottomBar
        }
        .navigationTitle(chatUser?.userName ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var chatMessages: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                ForEach(messageViewModel.chatMessages) { message in
                    VStack {
                        if message.fromId == Auth.auth().currentUser?.uid {
                            HStack {
                                Spacer()
                                HStack {
                                    Text(message.text)
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                .background(.customBlue)
                                .cornerRadius(8)
                            }
                        } else {
                            HStack {
                                HStack {
                                    Text(message.text)
                                        .foregroundStyle(.black)
                                }
                                .padding()
                                .background(.white)
                                .cornerRadius(8)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                HStack { Spacer() }
                    .id("Empty")
                    .onReceive(messageViewModel.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        }
                    }
            }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundStyle(Color(.darkGray))
            TextEditor(text: $messageViewModel.chatText)
                .opacity(messageViewModel.chatText.isEmpty ? 0.5 : 1)
                .frame(height: 40)
            Button {
                messageViewModel.handleSend()
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

//#Preview {
//    NavigationView {
//        ChatLogView()
//    }
//}
