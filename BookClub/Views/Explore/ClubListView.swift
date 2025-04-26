//
//  ClubListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/04/2025.
//

import SwiftUI

struct ClubListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    var clubsArr: [BookClub]  // original arr
    var coverImages: [UUID: UIImage]
    var clubCategory: String  // in-person or online clubs
    @State private var filteredArray: [BookClub] = []  // looped in ScrollView
    @State private var selectedGenre: String?  // genre Picker
    @State private var selectedSortBy: String?  // sort by Picker
    let sortByOptions: [String] = ["Name", "Newest"]
    
    var body: some View {
        VStack(alignment: .leading) {
            // filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Group {
                        // sort by
                        Menu {
                            Picker("Sort by", selection: $selectedSortBy) {
                                Text("Default")
                                    .tag(Optional<String>(nil))
                                ForEach(sortByOptions, id: \.self) {
                                    Text($0)
                                        .tag(Optional($0))
                                }
                            }
                            .onChange(of: selectedSortBy) {
                                filteredArray = bookClubViewModel.filterAndSortArray(clubsArr: clubsArr, selectedSortBy: selectedSortBy, selectedGenre: selectedGenre)
                            }
                        } label: {
                            HStack {
                                if let selectedSortBy {
                                    Text("Sort by: \(selectedSortBy)")
                                } else {
                                    Text("Sort by")
                                }
                                Image(systemName: "chevron.down")
                            }
                        }
                        .tint(selectedSortBy == nil ? .quaternaryHex : .accentColor)
                        .foregroundStyle(selectedSortBy == nil ? .black : .white)
                        
                        // genre
                        Menu {
                            Picker("Select genre", selection: $selectedGenre) {
                                Text("All Genres")
                                    .tag(Optional<String>(nil))
                                ForEach(bookClubViewModel.genreChoices, id: \.self) {
                                    Text($0)
                                        .tag(Optional($0))
                                }
                            }
                            .onChange(of: selectedGenre) {
                                filteredArray = bookClubViewModel.filterAndSortArray(clubsArr: clubsArr, selectedSortBy: selectedSortBy, selectedGenre: selectedGenre)
                            }
                        } label: {
                            HStack {
                                if let selectedGenre {
                                    Text(selectedGenre)
                                } else {
                                    Text("Genre")
                                }
                                Image(systemName: "chevron.down")
                            }
                        }
                        .tint(selectedGenre == nil ? .quaternaryHex : .accentColor)
                        .foregroundStyle(selectedGenre == nil ? .black : .white)
                    }
                    .foregroundStyle(.black)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    
                    if selectedGenre != nil || selectedSortBy != nil {
                        Button() {
                            // remove all filters - reset list
                            selectedGenre = nil
                            selectedSortBy = nil
                        } label: {
                            Text("Clear Filters")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.customBlue)
                        }
                    }
                }
                .scrollClipDisabled()
            }
            .padding(.bottom, 5)
                        
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(filteredArray) { club in
                    NavigationLink(destination: ClubHostView(bookClub: club, isModerator: club.moderatorName == authViewModel.currentUser?.name, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                        ViewTemplates.bookClubExploreList(coverImage: coverImages[club.id] ?? UIImage(), clubName: club.name)
                    }
                    .padding(.bottom, 8)
                }
            }
            .scrollClipDisabled()
            .clipShape(.rect)
        }
        .padding([.horizontal, .bottom])
        .navigationTitle("\(clubCategory) Book Clubs")
        .onAppear {
            if filteredArray.isEmpty {
                // make copy of clubsArr as @State var
                filteredArray = clubsArr
            }
        }
    }
}

#Preview {
    ClubListView(clubsArr: BookClubViewModel().allClubs, coverImages: [UUID():UIImage()], clubCategory: "In-Person")
}
