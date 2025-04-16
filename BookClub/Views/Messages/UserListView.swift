//
//  UserListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 16/04/2025.
//

import SwiftUI

struct UserListView: View {
    var users: [BookClubMembers]  // list of users can message
    var profilePics: [String: UIImage] = [:]
    @State private var selectedUser: BookClubMembers?
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(users) { user in
                    userRow(user: user, profilePic: profilePics[user.userId], selectedUser: $selectedUser)
                        .onTapGesture {
                            selectedUser = user
                        }
                }
            }
        }
        .padding()
        .navigationTitle("New Message")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
            }
        }
    }
}

// list of users you can message
struct userRow: View {
    var user: BookClubMembers
    var profilePic: UIImage?
    @Binding var selectedUser: BookClubMembers?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundStyle(user.userId == selectedUser?.userId ? .accent : .clear)
            
            HStack(spacing: 25) {
                if let profilePic = profilePic {
                    Image(uiImage: profilePic)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image("yellowIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading) {
                    Text(user.userName)
                    Text(user.bookClubName)
                }
                .padding([.bottom, .top])
                .foregroundStyle(user.userId == selectedUser?.userId ? .white : .primary)
                Spacer()
            }
            .padding(.leading)
        }
        Divider()
    }
}

//#Preview {
//    UserListView(users: <#[BookClubMembers]#>)
//}
