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
    var clubsArr: [BookClub]  // original arr of BookClubs
    var coverImages: [UUID: UIImage]
    var clubCategory: String  // in-person or online clubs
    //    @State var copiedArr: [BookClub] = []  // copy of clubsArr
    @State private var selectedGenre: String?  // for genre Picker
    @State private var selectedSortBy: String?
    let sortByOptions: [String] = ["Name", "Date Created"]
    
    @State private var filteredArray: [BookClub] = []  // looped in ScrollView
    
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
                                filteredArray = filterAndSortArray(clubsArr: clubsArr, selectedSortBy: selectedSortBy, selectedGenre: selectedGenre)
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
                                filteredArray = filterAndSortArray(clubsArr: clubsArr, selectedSortBy: selectedSortBy, selectedGenre: selectedGenre)
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
                .padding([.horizontal, .top])
            }
            .padding(.bottom, 5)
            
            // if filter has been applied - show button to clear filters
            //            if selectedGenre != nil || selectedSortBy != nil {
            //                HStack {
            //                    Spacer()
            //                    Button() {
            //                        // remove all filters - reset list
            //                        selectedGenre = nil
            //                        selectedSortBy = nil
            //                    } label: {
            //                        Text("Clear Filters")
            //                            .font(.subheadline)
            //                            .fontWeight(.medium)
            //                            .foregroundStyle(.customBlue)
            //                            .padding(.trailing)
            //                            .padding(.bottom, 5)
            //                    }
            //                }
            //            }
            
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(filteredArray) { club in
                    NavigationLink(destination: BookClubDetailsView(bookClub: club, isModerator: club.moderatorName == authViewModel.currentUser?.name ? true : false, isMember: bookClubViewModel.checkIsMember(bookClub: club))) {
                        ViewTemplates.bookClubExploreList(coverImage: coverImages[club.id] ?? UIImage(), clubName: club.name)
                            .padding(.top, 10)  // to show shadowing
                            .padding(.bottom, -5)
                    }
                }
            }
            .padding(.top, -10)  // reduce size of padding from showing shadows
            .padding(.horizontal)
        }
        .navigationTitle("\(clubCategory) Book Clubs")
        .onAppear {
            if filteredArray.isEmpty {
                // make copy of clubsArr as @State var
                filteredArray = clubsArr
            }
        }
    }
}

func filterAndSortArray(clubsArr: [BookClub], selectedSortBy: String?, selectedGenre: String?) -> [BookClub] {
    var filteredArray = clubsArr
    
    if let selectedGenre {
        filteredArray = filteredArray.filter { $0.genre == selectedGenre }
    }
    
    switch selectedSortBy {
    case "Date Created":
        // sort in alphabetical order
        filteredArray = filteredArray.sorted { $0.creationDate > $1.creationDate }
    case "Name":
        // sort by date created - newest first
        filteredArray = filteredArray.sorted { $0.name.lowercased() < $1.name.lowercased() }
    default:
        break
    }
    
    return filteredArray
}

#Preview {
    ClubListView(clubsArr: BookClubViewModel().allClubs, coverImages: [UUID():UIImage()], clubCategory: "In-Person")
}
