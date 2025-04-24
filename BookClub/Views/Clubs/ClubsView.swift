//
//  ClubsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

// clubs tab with segmented picker

import SwiftUI
import FirebaseAuth

struct ClubsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var bookViewModel: BookViewModel
    @State private var selectedItem: Int = 0  // for Picker
    @State private var selectedFilter: Int = 0  // for club type filters
    @State private var selectedClub: BookClub?  // when tap on a club in list
    @State private var showClubDetails: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // title
            HStack {
                Text("Your Clubs")
                    .font(.largeTitle).bold()
                
                if selectedItem == 1 {
                    Spacer()
                    // make new club
                    NavigationLink(destination: CreateClubView()) {
                        Label("Create new club", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 24))
                    }
                }
            }
            
            // segmented control
            Picker(
                "Joined and created clubs",
                selection: $selectedItem
            ){
                Text("Joined Clubs").tag(0)
                Text("Created Clubs").tag(1)
            }
            .pickerStyle(.segmented)
            
            // club type filters
            HStack {
                Button("All") {
                    selectedFilter = 0
                }
                .tag(0)
                .tint(selectedFilter == 0 ? .accent : .quaternaryHex)
                .foregroundStyle(selectedFilter == 0 ? .white : .black)
                
                Button("In-Person") {
                    selectedFilter = 1
                }
                .tag(1)
                .tint(selectedFilter == 1 ? .customYellow : .customYellow.opacity(0.2))
                
                Button("Online") {
                    selectedFilter = 2
                }
                .tag(2)
                .tint(selectedFilter == 2 ? .customGreen : .customGreen.opacity(0.2))
            }
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundStyle(.black)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            
            if selectedItem == 0 {
                // joined clubs list
                List {
                    ForEach(bookClubViewModel.joinedClubs.sorted(by: { $0.name < $1.name })) { club in
                        if selectedFilter == 0 || selectedFilter == 1 && club.meetingType == "In-Person" || selectedFilter == 2 && club.meetingType == "Online" {
                            ClubsCardView(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name)
                                .background(
                                    // hide navigation link arrows
                                    NavigationLink("", destination: ClubHostView(bookClub: club, isModerator: false, isMember: true, coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage()))
                                        .opacity(0)
                                )
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 12, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            } else {
                // created clubs list
                List {
                    ForEach(bookClubViewModel.createdClubs.sorted(by: { $0.name < $1.name })) { club in
                        // check what club filter is selected
                        if selectedFilter == 0 || selectedFilter == 1 && club.meetingType == "In-Person" || selectedFilter == 2 && club.meetingType == "Online" {
                            ClubsCardView(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name)
                                .background(
                                    // hide navigation link arrows
                                    NavigationLink("", destination: ClubHostView(bookClub: club, isModerator: club.moderatorName == authViewModel.currentUser?.name ? true : false, isMember: false, coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage()))
                                        .opacity(0)
                                )
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 12, trailing: 0))  // set padding of each row
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        .padding()
    }
}

#Preview {
    ClubsView()
        .environmentObject(BookClubViewModel())
        .environmentObject(EventViewModel())
}
