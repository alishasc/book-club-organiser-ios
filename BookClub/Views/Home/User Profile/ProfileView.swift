//
//  UserProfileView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var profile: User
    var profilePic: UIImage
    var joinedClubs: Int
    var createdClubs: Int
    
    var body: some View {
        VStack(spacing: 30) {
            personalDetails
            clubsCount
            genreAndLocation
            Spacer()
            logOutButton
        }
        .padding()
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton() // check apple landmarks project for this
            }
        }
    }
    
    private var personalDetails: some View {
        VStack {
            // profile picture
            Image(uiImage: profilePic)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            Text(profile.name)
                .font(.title)
                .fontWeight(.semibold)
            Text(profile.email)
                .fontWeight(.medium)
        }
    }
    private var clubsCount: some View {
        // clubs joined/created
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 270, height: 80)
                .foregroundStyle(.quinary)
            
            HStack {
                Spacer()
                Spacer()
                VStack {
                    Text("\(joinedClubs)")
                        .font(.title2).bold()
                    Text("clubs joined")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack {
                    Text("\(createdClubs)")
                        .font(.title2).bold()
                    Text("clubs created")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Spacer()
                Spacer()
            }
        }
    }
    private var genreAndLocation: some View {
        // genres and location
        VStack(spacing: 15) {
            VStack(alignment: .leading) {
                Text("Favourite Genres")
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
                
                if !profile.favouriteGenres.isEmpty {
                    Text(profile.favouriteGenres.joined(separator: ", "))
                        .font(.subheadline)
                        .padding(.bottom, -5)
                } else {
                    Text("No genres selected")
                        .font(.subheadline)
                        .padding(.bottom, -5)
                }
                Divider()
            }
            VStack(alignment: .leading) {
                Text("Location")
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
                // if user didn't select a location when signed up
                if profile.location == "" {
                    Text("No location selected")
                        .font(.subheadline)
                        .padding(.bottom, -5)
                } else {
                    Text(profile.location)
                        .font(.subheadline)
                        .padding(.bottom, -5)
                }
                Divider()
            }
        }
    }
    private var logOutButton: some View {
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
}

//#Preview {
//    ProfileView(bookClubViewModel: BookClubViewModel(), authViewModel: AuthViewModel())
//}
