//
//  UserProfileView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // title
            HStack {
                Text("My Profile")
                    .font(.largeTitle).bold()
                Spacer()
            }
            
            // personal details
            VStack {
                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.quinary)
                Text("Name")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("email@example.com")
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
            
            // info from onboarding
            VStack(spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Favourite Genres")
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("Genres listed here")
                        .font(.subheadline)
                        .padding(.bottom, -5)
                    Divider()
                }
                VStack(alignment: .leading) {
                    Text("Location")
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)
                    Text("Chosen location here")
                        .font(.subheadline)
                        .padding(.bottom, -5)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
            }
        }
    }
}

#Preview {
    UserProfileView()
}
