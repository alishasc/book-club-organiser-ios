//
//  ClubsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct ClubsView: View {
    @State private var selectedItem: Int = 0  // for Picker
    @State private var selectedFilter: Int = 0  // for club type filters

    var body: some View {
        VStack(alignment: .leading) {
            // header
            if selectedItem == 0 {
                Text("Your Clubs")
                    .font(.largeTitle).bold()
            } else {
                HStack {
                    Text("Your Clubs")
                        .font(.largeTitle).bold()
                    Spacer()
                    // make new club
                    NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
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
                .font(.footnote)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(selectedFilter == 0 ? .accent : .secondary)
                
                Button("In-Person") {
                    selectedFilter = 1
                }
                .tag(1)
                .font(.footnote)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(selectedFilter == 1 ? .accent : .secondary)
                
                Button("Online") {
                    selectedFilter = 2
                }
                .tag(2)
                .font(.footnote)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(selectedFilter == 2 ? .accent : .secondary)
            }
            
            if selectedItem == 0 {
                // joined clubs list
                ScrollView(.vertical) {
                    ClubsListView()
                    ClubsListView()
                }
            } else {
                // created clubs list
                ScrollView(.vertical) {
                    ClubsListView()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ClubsView()
}
