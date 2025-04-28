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
    @State private var selectedCategory: Int = 0
    @State private var showUpcomingEvents: Bool = true  // chevron icon
    @State private var showDiscoverEvents: Bool = true  // chevron icon
    @State private var selectedClubName: String?  // filter by book club
    
    var body: some View {
        VStack(alignment: .leading) {
            // title
            Text("Events")
                .font(.largeTitle).bold()
                .padding([.top, .horizontal])
            
            filters  // event type/book club
            dateFilters
            
            // event lists
            ScrollView(.vertical, showsIndicators: false) {
                //                 your upcoming events
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
                            ForEach(eventViewModel.filteredUpcomingEvents(selectedFilter: selectedCategory, bookClubViewModel: bookClubViewModel, selectedClubName: selectedClubName), id: \.event.id) { event, bookClub in
                                EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorId == authViewModel.currentUser?.id)
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
                            ForEach(eventViewModel.filteredDiscoverEvents(selectedFilter: selectedCategory, bookClubViewModel: bookClubViewModel, selectedClubName: selectedClubName), id: \.event.id) { event, bookClub in
                                EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorId == authViewModel.currentUser?.id)
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
            // reset all filters when leave page
            selectedCategory = 0  // show all events
            eventViewModel.currentDay = nil
        }
        .onChange(of: selectedClubName) {
            // unselect other categories if a club is selected
            if selectedClubName != nil {
                selectedCategory = 0
            }
        }
    }
    
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Group {
                    Button("All") {
                        selectedCategory = 0
                        selectedClubName = nil
                    }
                    .tint(selectedCategory == 0 && selectedClubName == nil ? .accent : .quaternaryHex)
                    .foregroundStyle(selectedCategory == 0 && selectedClubName == nil ? .white : .black)
                    
                    Button("In-Person") {
                        selectedCategory = 1
                        selectedClubName = nil
                    }
                    .tint(selectedCategory == 1 ? .customYellow : .customYellow.opacity(0.2))
                    
                    Button("Online") {
                        selectedCategory = 2
                        selectedClubName = nil
                    }
                    .tint(selectedCategory == 2 ? .customGreen : .customGreen.opacity(0.2))
                    
                    Button("Created Events") {
                        selectedCategory = 3
                        selectedClubName = nil
                    }
                    .tint(selectedCategory == 3 ? .customPink : .customPink.opacity(0.2))
                    
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
            HStack(spacing: 8) {
                ForEach(eventViewModel.currentWeek, id: \.self) { day in
                    VStack(spacing: 10) {
                        Text(eventViewModel.extractDate(date: day, format: "EEE"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(eventViewModel.extractDate(date: day, format: "dd"))
                            .font(.subheadline)
                        
                        HStack(spacing: 3) {
                            let colors = eventViewModel.eventColors(date: day)
                            
                            ForEach(colors.indices, id: \.self) { index in
                                Circle()
                                    .fill(colors[index])
                                    .frame(width: 8, height: 8)
                            }
                            if colors.count == 0 {
                                Circle()
                                    .fill(.clear)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .foregroundStyle(eventViewModel.currentDay == day ? .white : .black)
                    .foregroundStyle(.black)
                    // capsule shape
                    .frame(width: 45, height: 90)
                    .background(
                        ZStack {
                            if eventViewModel.currentDay == day {
                                Capsule()
                                    .fill(.accent)
                            }
                            else {
                                Capsule()
                                    .fill(Color(.systemGray6))
                            }
                        }
                    )
                    .contentShape(Capsule())
                    .onTapGesture {
                        if eventViewModel.currentDay == day {
                            eventViewModel.currentDay = nil
                        } else {
                            eventViewModel.currentDay = day
                        }
                    }
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

// EventDatesView(dateStr: eventViewModel.extractDate(date: day, format: "EEE"), dateInt: eventViewModel.extractDate(date: day, format: "dd"))
