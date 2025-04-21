//
//  MessagesView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @ObservedObject var messageViewModel: MessageViewModel
    
    @State private var showNewMessageScreen: Bool = false
    @State private var showChatLogView: Bool = false
    @State var chatUser: BookClubMembers?
    
    var body: some View {
        NavigationStack {
            VStack {
                messageHeader
                
                if messageViewModel.recentMessages.isEmpty {
                    ContentUnavailableView {
                        Label("No Messages", systemImage: "bubble.fill")
                    } description: {
                        Text("New messages you receive will appear here.")
                    }
                } else {
                    messageList
                }
            }
            .navigationDestination(isPresented: $showChatLogView, destination: {
                ChatLogView(chatUser: self.chatUser)
            })
        }
    }
    
    private var messageHeader: some View {
        HStack {
            Text("Messages")
                .font(.largeTitle).bold()
            Spacer()
            // new message button
            Button {
                showNewMessageScreen.toggle()
            } label: {
                Label("New message", systemImage: "square.and.pencil")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 24))
            }
            .fullScreenCover(isPresented: $showNewMessageScreen) {
                NewMessageView(didSelectNewUser: { user in
                    self.showChatLogView.toggle()
                    self.chatUser = user
                })
            }
        }
        .padding()
    }
    
    private var messageList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(messageViewModel.recentMessages) { recentMessage in
                NavigationLink {
                    ChatLogView(chatUser: chatUser)
                } label: {
                    HStack(spacing: 20) {
                        if let profilePic = bookClubViewModel.memberPics[recentMessage.toId] {
                            Image(uiImage: profilePic)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.black, lineWidth: 1))
                                .shadow(radius: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recentMessage.userName)
                                .foregroundStyle(.black)
                                .font(.system(size: 16, weight: .semibold))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(recentMessage.text)
                                .foregroundStyle(Color(.lightGray))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Text(recentMessage.timestamp.description)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal)
                }
                Divider()
                    .padding(.vertical, 8)
            }
        }
    }
}

//#Preview {
//    MessagesView()
//}
