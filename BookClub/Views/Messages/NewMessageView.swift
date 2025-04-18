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
                ForEach(bookClubViewModel.messageUsers) { user in
                    Button {
                        dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 20) {
                            if let profilePic = bookClubViewModel.memberPics[user.userId] {
                                Image(uiImage: profilePic)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.black, lineWidth: 2))
                            } else {
                                Image("blueIcon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .overlay(Circle().stroke(.black, lineWidth: 2))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(user.userName)
                                Text(user.bookClubName)
                            }
                            .padding([.bottom, .top])
                            Spacer()
                        }
                        .padding(.leading)
                    }

                    Divider()
                }
            }
            .padding()
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
