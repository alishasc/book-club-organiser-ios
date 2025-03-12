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
                .tint(selectedFilter == 0 ? .accent : .accent.opacity(0.2))
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
            .foregroundStyle(.black)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            
            if selectedItem == 0 {
                // joined clubs list
                List {
                    ClubsCardView(coverImage: UIImage(), clubName: "joined club name")  // hardcoded - change this
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 12, trailing: 0))
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            } else {
                // created clubs list
                List {
                    ForEach(bookClubViewModel.createdClubs) { club in
                        // check what club filter is selected
                        if selectedFilter == 0 || selectedFilter == 1 && club.meetingType == "In-Person" || selectedFilter == 2 && club.meetingType == "Online" {
                            ClubsCardView(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name)
                                .onTapGesture {
                                    // to get the details of the selected club
                                    selectedClub = club
                                    
                                    // if the selected club has an id
                                    if let selectedClubId = selectedClub?.id {
                                        Task {
                                            // fetch selected club and moderator details
                                            try await bookClubViewModel.fetchBookClubDetails(bookClubId: selectedClubId)
                                            
                                            // trigger club details screen to show
                                            showClubDetails = true
                                        }
                                    }
                                }
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
        .onAppear {
            Task {
                // try fetching any created clubs if any
                try await bookClubViewModel.fetchCreatedBookClubs()
            }
        }
        // show book club details page for new club
        .navigationDestination(isPresented: $showClubDetails) {
            // if book club has been selected
            if let selectedClub {
                BookClubDetailsView(bookClub: selectedClub, moderatorName: bookClubViewModel.moderatorName, isModerator: bookClubViewModel.moderatorName == authViewModel.currentUser?.name ? true : false)
            }
        }
    }
}

#Preview {
    ClubsView()
        .environmentObject(BookClubViewModel())
        .environmentObject(EventViewModel())
}
