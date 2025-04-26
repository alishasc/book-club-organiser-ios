//
//  NewMessageView.swift
//  BookClub
//
//  Created by Alisha Carrington on 16/04/2025.
//

import SwiftUI

struct NewMessageView: View {
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @Environment(\.dismiss) var dismiss
    
    let didSelectNewUser: (BookClubMembers) -> ()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(bookClubViewModel.contacts) { user in
                    Button {
                        dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 20) {
                            if let profilePic = bookClubViewModel.memberPics[user.userId] {
                                Image(uiImage: profilePic)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.black, lineWidth: 1))
                                    .shadow(radius: 2)
                            } else {
                                Image("blueIcon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .overlay(Circle().stroke(.black, lineWidth: 1))
                                    .shadow(radius: 2)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.userName)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16, weight: .semibold))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                Text(user.bookClubName)
                                    .foregroundStyle(Color(.lightGray))
                                    .lineLimit(1)
                            }
                            .padding([.bottom, .top])
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
//            .padding()
            .scrollClipDisabled()
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    UserListView(users: <#[BookClubMembers]#>)
//}

