//
//  ExploreView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    let genreFilter: [String] = ["All", "Contemporary", "Fantasy", "Mystery", "Romance", "Thriller"]
    @State private var searchInput: String = ""
    
    @State private var isMember: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Explore")
                    .font(.largeTitle).bold()
                    .padding([.top, .horizontal])
                
                // search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 10)  // inside textfield
                    TextField("Search club name, genre, location", text: $searchInput)
                        .padding([.top, .bottom, .trailing], 10)  // inside textfield
                }
                .background(.quinary)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // circle genre filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(genreFilter.indices, id: \.self) { filter in
                            VStack {
                                Circle()
                                    .frame(width: 90, height: 90)
                                    .foregroundStyle(.quinary)
                                Text(genreFilter[filter])
                                    .font(.footnote)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // popular clubs
                VStack(alignment: .leading, spacing: 10) {
                    Text("Popular Clubs")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
//                        }
//                        .padding(.horizontal)
                    }
                }
                
                // online book clubs
                VStack(spacing: 10) {
                    HStack {
                        Text("Online Book Clubs")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                            Text("View all")
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(bookClubViewModel.allClubs) { club in
                                if club.meetingType == "Online" {
                                    NavigationLink(destination: BookClubDetailsView(bookClub: club, isModerator: club.moderatorName == authViewModel.currentUser?.name ? true : false, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                                        ViewTemplates.bookClubRow(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // in-person book clubs
                VStack(spacing: 10) {
                    HStack {
                        Text("In-Person Book Clubs")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                            Text("View all")
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(bookClubViewModel.allClubs) { club in
                                if club.meetingType == "In-Person" {
                                    NavigationLink(destination: BookClubDetailsView(bookClub: club, isModerator: club.moderatorName == authViewModel.currentUser?.name, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                                        ViewTemplates.bookClubRow(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    ExploreView()
}
