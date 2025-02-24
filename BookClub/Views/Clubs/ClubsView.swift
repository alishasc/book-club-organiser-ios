//
//  ClubsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI
import FirebaseAuth

// clubs tab with segmented picker

struct ClubsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var bookClubViewModel: BookClubViewModel
    @State private var selectedItem: Int = 0  // for Picker
    @State private var selectedFilter: Int = 0  // for club type filters
    @State private var selectedClub: BookClub?  // when tap on a club in list
    @State private var showClubDetails: Bool = false
    @State private var isModerator: Bool = false
    @State private var isOnline: Bool = false
    
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
            
            if selectedItem == 0 {
                // joined clubs list
                List {
                    ClubsListView(clubName: "joined club name")  // hardcoded - change this
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 12, trailing: 0))
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            } else {
                // created clubs list
                List {
                    ForEach(bookClubViewModel.createdClubs) { club in
                        ClubsListView(clubName: club.name)
                            .onTapGesture {
                                // get the details of the selected club
                                selectedClub = club
                                
                                // if the selected club has an id
                                if let selectedClubId = selectedClub?.id {
                                    Task {
                                        // fetch tapped book clubs details from firestore
                                        try await bookClubViewModel.fetchOneBookClub(bookClubId: selectedClubId)
                                        try await bookClubViewModel.fetchModeratorDetails(moderatorId: bookClubViewModel.bookClub?.moderatorId ?? "")
                                        // trigger club details screen to show
                                        showClubDetails = true
                                    }
                                }
                            }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 12, trailing: 0))  // set padding of each row
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            Task {
                // try fetching any created clubs if any
                try await bookClubViewModel.fetchCreatedBookClubs()
            }
        }
        // fix this!!
        .navigationDestination(isPresented: $showClubDetails) {
            if let bookClub = bookClubViewModel.bookClub {
                BookClubDetailsView(bookClub: bookClub, moderatorName: bookClubViewModel.moderatorName, isModerator: bookClubViewModel.moderatorName == authViewModel.currentUser?.name ? true : false, isOnline: isOnline)
            }
        }
    }
}

#Preview {
    ClubsView(bookClubViewModel: BookClubViewModel())
}
