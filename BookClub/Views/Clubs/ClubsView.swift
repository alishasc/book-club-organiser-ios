//
//  ClubsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

// clubs tab with segmented picker

struct ClubsView: View {
    @StateObject var bookClubViewModel: BookClubViewModel
    @State private var selectedItem: Int = 0  // for Picker
    @State private var selectedFilter: Int = 0  // for club type filters

    var body: some View {
        VStack(alignment: .leading) {
            // header
            if selectedItem == 0 {
                Text("Clubs")
                    .font(.largeTitle).bold()
            } else {
                HStack {
                    Text("Clubs")
                        .font(.largeTitle).bold()
                    Spacer()
                    // make new club
                    NavigationLink(destination: CreateClubView(bookClubViewModel: bookClubViewModel)) {
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
                .tint(selectedFilter == 0 ? .accent : .secondary)
                
                Button("In-Person") {
                    selectedFilter = 1
                }
                .tag(1)
                .tint(selectedFilter == 1 ? .accent : .secondary)
                
                Button("Online") {
                    selectedFilter = 2
                }
                .tag(2)
                .tint(selectedFilter == 2 ? .accent : .secondary)
            }
            .font(.footnote)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            
            // joined clubs = 0
            if selectedItem == 0 {
                // joined clubs list
                ScrollView(.vertical, showsIndicators: false) {
                    ClubsListView(clubName: "joined club name")  // hardcoded - change this
                }
            } else {
                // created clubs list
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(bookClubViewModel.createdClubs) { club in
                        ClubsListView(clubName: club.name)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                // try fetching any created clubs if any
                try await bookClubViewModel.fetchCreatedBookClubs()
            }
        }
    }
}

#Preview {
    ClubsView(bookClubViewModel: BookClubViewModel())
}
