//
//  EventsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI
import FirebaseAuth
import UIKit

struct EventsView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedFilter: Int = 0
    @State private var showUpcomingEvents: Bool = true
    @State private var showDiscoverEvents: Bool = true
    
    //    @State private var selectedDate: Date = Date()
    
    @State private var selectedClubName: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            // title
            Text("Events")
                .font(.largeTitle).bold()
                .padding([.top, .horizontal])
            
            // event type filters
            filters
            // dates
            dateFilters
            
            // event lists
            ScrollView(.vertical, showsIndicators: false) {
                // your upcoming events
                VStack(spacing: 10) {
                    HStack {
                        Text("Your Upcoming Events")
                        Spacer()
                        Button {
                            // show/hide event list
                            showUpcomingEvents.toggle()
                        } label: {
                            Label("Toggle upcoming events", systemImage: showUpcomingEvents ? "chevron.up" : "chevron.down")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.customBlue)
                        }
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    
                    if showUpcomingEvents {
                        // events joined scrollview
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(eventViewModel.filteredUpcomingEvents(selectedFilter: selectedFilter, bookClubViewModel: bookClubViewModel, selectedClubName: selectedClubName), id: \.event.id) { event, bookClub in
                                EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorName == authViewModel.currentUser?.name)
                                    .padding(.bottom, 8)
                            }
                        }
                        .scrollClipDisabled()
                    }
                }
                
                // discover events
                VStack(spacing: 10) {
                    HStack {
                        Text("Discover Events")
                        Spacer()
                        Button {
                            // show/hide event list
                            showDiscoverEvents.toggle()
                        } label: {
                            Label("Toggle upcoming events", systemImage: showDiscoverEvents ? "chevron.up" : "chevron.down")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.customBlue)
                        }
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                    
                    if showDiscoverEvents {
                        // events haven't joined scrollview
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(eventViewModel.filteredDiscoverEvents(selectedFilter: selectedFilter, bookClubViewModel: bookClubViewModel, selectedClubName: selectedClubName), id: \.event.id) { event, bookClub in
                                EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorName == authViewModel.currentUser?.name)
                                    .padding(.bottom, 8)
                            }
                        }
                        .scrollClipDisabled()
                    }
                }
            }
            .padding([.bottom, .horizontal])
            .scrollClipDisabled()
            .clipShape(.rect)
            
            Spacer()
        }
        .onDisappear {
            selectedFilter = 0  // show all events
        }
    }
    
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Group {
                    Button("All") {
                        selectedFilter = 0
                        selectedClubName = nil
                    }
                    .tint(selectedFilter == 0 && selectedClubName == nil ? .accent : .quaternaryHex)
                    .foregroundStyle(selectedFilter == 0 && selectedClubName == nil ? .white : .black)
                    
                    Button("In-Person") {
                        selectedFilter = 1
                        selectedClubName = nil
                    }
                    .tint(selectedFilter == 1 ? .customYellow : .customYellow.opacity(0.2))
                    
                    Button("Online") {
                        selectedFilter = 2
                        selectedClubName = nil
                    }
                    .tint(selectedFilter == 2 ? .customGreen : .customGreen.opacity(0.2))
                    
                    Button("Created Events") {
                        selectedFilter = 3
                        selectedClubName = nil
                    }
                    .tint(selectedFilter == 3 ? .customPink : .customPink.opacity(0.2))
                    
                    // filter by book club - both created and joined clubs
                    Menu {
                        Picker("Book Club", selection: $selectedClubName) {
                            Text("All Book Clubs")
                                .tag(Optional<String>(nil))
                            ForEach(bookClubViewModel.joinedAndCreatedClubNames(), id: \.self) {
                                Text($0)
                                    .tag(Optional($0))
                            }
                        }
                    } label: {
                        HStack {
                            if let selectedClubName {
                                Text(selectedClubName)
                            } else {
                                Text("Book Club")
                            }
                            Image(systemName: "chevron.down")
                        }
                    }
                    .tint(selectedClubName == nil ? .quaternaryHex : .accentColor)
                    .foregroundStyle(selectedClubName == nil ? .black : .white)
                }
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.black)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
            .padding(.horizontal)
        }
    }
    private var dateFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(1..<8) { index in
                    EventDatesView(dateStr: "Mon", dateInt: index)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    EventsView()
}
