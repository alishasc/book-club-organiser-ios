//
//  UserProfileView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct ProfileView: View {
    var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // personal details
            VStack {
                // profile picture
                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.quinary)
                Text(authViewModel.currentUser?.name ?? "")
                    .font(.title)
                    .fontWeight(.semibold)
                Text(authViewModel.currentUser?.email ?? "")
                    .fontWeight(.medium)
            }
            
            // clubs joined/created
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 270, height: 80)
                    .foregroundStyle(.quinary)
                
                HStack {
                    Spacer()
                    Spacer()
                    VStack {
                        Text("0")
                            .font(.title2).bold()
                        Text("clubs joined")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    VStack {
                        Text("0")
                            .font(.title2).bold()
                        Text("clubs created")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    Spacer()
                }
            }
            
            // genres and location
            VStack(spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Favourite Genres")
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    
                    Text(authViewModel.currentUser?.favouriteGenres.joined(separator: ", ") ?? "No genres selected")
                        .font(.subheadline)
                        .padding(.bottom, -5)
                    Divider()
                }
                VStack(alignment: .leading) {
                    Text("Location")
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    if let location = authViewModel.currentUser?.location {
                        // if user didn't select a location when signed up
                        if location == "" {
                            Text("No location selected")
                                .font(.subheadline)
                                .padding(.bottom, -5)
                        } else {
                            Text(location)
                                .font(.subheadline)
                                .padding(.bottom, -5)
                        }
                    }
                    Divider()
                }
            }
            
            Spacer()
            
            // log out button
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 350, height: 45)
                    .foregroundStyle(.quinary)
                
                Button("Log out") {
                    authViewModel.logOut()
                }
                .padding(.leading)
            }
        }
        .padding()
        .navigationTitle("My Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
//                Button("Edit") {
//                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
//                }
                
                EditButton() // check apple landmarks project for this
            }
        }
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
