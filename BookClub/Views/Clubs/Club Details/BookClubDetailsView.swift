//
//  BookClubDetailsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct BookClubDetailsView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // cover image and title
                ZStack(alignment: .bottomLeading) {
                    // cover image
                    Rectangle()
                        .frame(height: 200)
                        .foregroundStyle(.customGreen)
                        .background(
                            Image("PATH_TO_IMAGE")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        )
                    // title
                    Text("Book Club Name")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding([.leading, .bottom], 15)
                }
                
                VStack(spacing: 20) {
                    // moderator and members info
                    ClubDetailsMembersView()
                    
                    ClubDetailsAboutView(description: "A book club for fantasy lovers who enjoy exploring captivating worlds, complex characters, and thought provoking stories. Join us for engaging discussions and discover new adventures in every book!")
                    
                    ClubDetailsCRView(title: "Onyx Storm", author: "Rebecca Yarros", genre: "Fantasy", synopsis: "After nearly eighteen months at Basgiath War College, Violet Sorrengail knows there's no more time for lessons. No more time for uncertainty. Because the battle has truly begun, and with enemies closing in from outside their walls and within their ranks, it's impossible to know who to trust.")
                }
                .padding(.horizontal)
                    
                ClubDetailsPRView()
                    
                VStack {
                    ClubDetailsEventsView()
                }
                .padding([.horizontal, .bottom])
            }
            .navigationBarBackButtonHidden(true)
        }
        .ignoresSafeArea(SafeAreaRegions.all, edges: .top)
    }
}

#Preview {
    BookClubDetailsView()
}
