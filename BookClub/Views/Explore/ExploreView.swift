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
    @State var genres: [String] = []  // displayed filters
    @State private var selectedGenre: String = "All"  // selected filter
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Explore")
                    .font(.largeTitle).bold()
                    .padding([.top, .horizontal])
                
                NavigationLink {
                    ExploreSearchView()
                } label: {
                    // search bar
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.quinary)
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .padding(.leading, 10)
                            Text("Search club name or genre")
                                .padding([.top, .bottom, .trailing], 10)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)

                // circle genre filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(genres, id: \.self) { genre in
                            VStack {
                                if let uiImage = UIImage(named: "\(genre.lowercased())Icon") {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: genre == selectedGenre ? 100 : 85, height: genre == selectedGenre ? 100 : 85)
                                        .clipShape(Circle())
                                } else if genre == "All" {
                                    Image("allGenres")
                                        .resizable()
                                        .frame(width: genre == selectedGenre ? 100 : 85, height: genre == selectedGenre ? 100 : 85)
                                        .clipShape(Circle())
                                } else {
                                    Image("favouriteGenres")
                                        .resizable()
                                        .frame(width: genre == selectedGenre ? 100 : 85, height: genre == selectedGenre ? 100 : 85)
                                        .clipShape(Circle())
                                }
                                Text(genre)
                                    .font(.footnote)
                                    .scaleEffect(genre == selectedGenre ? 1.1 : 1)
                                    .fontWeight(genre == selectedGenre ? .semibold : .regular)
                            }
                            .onTapGesture {
                                withAnimation {
                                    selectedGenre = genre
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollClipDisabled()
                
                // popular clubs
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Popular Clubs")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.horizontal)
//                    
//                    ScrollView(.horizontal, showsIndicators: false) {
////                        HStack {
////                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
////                        }
////                        .padding(.horizontal)
//                    }
//                }
                
                // online book clubs
                VStack(spacing: 10) {
                    HStack {
                        Text("Online Book Clubs")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        NavigationLink(destination: ClubListView(clubsArr: bookClubViewModel.allClubs.filter({ $0.meetingType == "Online" && $0.isPublic && (selectedGenre != "All" ? $0.genre == selectedGenre : true) }), coverImages: bookClubViewModel.coverImages, clubCategory: "Online")) {
                            Text("View all")
                                .foregroundStyle(.customBlue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(bookClubViewModel.allClubs) { club in
                                if club.meetingType == "Online" && club.isPublic == true &&
                                    (selectedGenre != "All" ? club.genre == selectedGenre : true) {
                                    NavigationLink(destination: ClubHostView(bookClub: club, isModerator: club.moderatorId == authViewModel.currentUser?.id, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                                        ViewTemplates.bookClubRow(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name, clubGenre: club.genre)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollClipDisabled()
                }
                
                // in-person book clubs
                VStack(spacing: 10) {
                    HStack {
                        Text("In-Person Book Clubs")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        NavigationLink(destination: ClubListView(clubsArr: bookClubViewModel.allClubs.filter({ $0.meetingType == "In-Person" && $0.isPublic && (selectedGenre != "All" ? $0.genre == selectedGenre : true) }), coverImages: bookClubViewModel.coverImages, clubCategory: "In-Person")) {
                            Text("View all")
                                .foregroundStyle(.customBlue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(bookClubViewModel.allClubs) { club in
                                if club.meetingType == "In-Person" && club.isPublic == true &&
                                    (selectedGenre != "All" ? club.genre == selectedGenre : true) {
                                    NavigationLink(destination: ClubHostView(bookClub: club, isModerator: club.moderatorId == authViewModel.currentUser?.id, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                                        ViewTemplates.bookClubRow(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name, clubGenre: club.genre)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollClipDisabled()
                }
            }
            .padding(.bottom)
        }
        .onAppear {
            if let favouriteGenres = authViewModel.currentUser?.favouriteGenres.sorted(by: { $0.lowercased() < $1.lowercased() }) {
                var genreSet: Set<String> = []  // so only one of each genre
                for genre in ["All"] + favouriteGenres + ["Contemporary", "Fantasy", "Mystery", "Romance", "Thriller"] {
                    genreSet.insert(genre)
                }
                genres = Array(genreSet.sorted(by: { $0.lowercased() < $1.lowercased() }))
            }
        }
    }
}

//#Preview {
//    ExploreView()
//}
