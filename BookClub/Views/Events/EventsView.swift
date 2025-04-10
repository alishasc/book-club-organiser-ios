//
//  EventsView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI
import FirebaseAuth

struct EventsView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedFilter: Int = 0
    @State private var showUpcomingEvents: Bool = true
    @State private var showDiscoverEvents: Bool = true
    
    @State private var selectedClubName: String = ""  // doing nothing atm
        
    var body: some View {
        VStack(alignment: .leading) {
            // title
            Text("Events")
                .font(.largeTitle).bold()
                .padding([.top, .horizontal])
            
            // event type filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Group {
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

                        Button("Created Events") {
                            selectedFilter = 3
                        }
                        .tag(3)
                        .tint(selectedFilter == 3 ? .customPink : .customPink.opacity(0.2))
                        
                        // filter by book club
                        Menu {
                            // put list of book clubs joined and created
                            ForEach(bookClubViewModel.joinedClubs) { club in
                                Button("\(club.name)") {
                                    selectedFilter = 5
                                    selectedClubName = club.name
                                }
                            }
                        } label: {
                            HStack {
                                Text("Book Club")
                                Image(systemName: "chevron.down")
                            }
                        }
                        .tint(.quaternaryHex)
                        .foregroundStyle(.black)
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
                .padding(.horizontal)
            }
            
            // dates
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(1..<8) { index in
                        EventDatesView(dateStr: "Mon", dateInt: index)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 5)
            
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
                        }
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    
                    if showUpcomingEvents {
                        // events scrollview
//                        ScrollView(.vertical, showsIndicators: false) {
//                            ForEach(eventViewModel.joinedEvents) { event in
//                                if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
//                                    EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorName == authViewModel.currentUser?.name)
//                                        .padding(.bottom, 8)
//                                }
//                            }
//                        }
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            if selectedFilter != 4 {
                                ForEach(testFilter(selectedFilter: selectedFilter)) { event in
                                    if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
                                        EventsRowView(bookClub: bookClub, event: event, coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(), isModerator: bookClub.moderatorName == authViewModel.currentUser?.name)
                                            .padding(.bottom, 8)
                                    }
                                }
                            }
                        }
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
                        }
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 15)
                    
                    if showDiscoverEvents {
                        // events scrollview
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(eventViewModel.allEvents.filter { event in
                                // Event is from a joined club AND not already joined
                                bookClubViewModel.joinedClubs.contains(where: { $0.id == event.bookClubId }) &&
                                !eventViewModel.joinedEvents.contains(where: { $0.id == event.id })
                            }) { event in
                                if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
                                    EventsRowView(
                                        bookClub: bookClub,
                                        event: event,
                                        coverImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage(),
                                        isModerator: bookClub.moderatorName == authViewModel.currentUser?.name
                                    )
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                    }
                }
            }
            .padding([.bottom, .horizontal])
            
            Spacer()
        }
        .onDisappear {
            selectedFilter = 0
        }
    }
    
    // for upcoming events atm
    func testFilter(selectedFilter: Int) -> [Event] {
        var selectedFilterStr: String = ""
        var eventArr: [Event] = []
        
        // convert selectedFilter into a String value
        switch selectedFilter {
        case 1:
            selectedFilterStr = "In-Person"
        case 2:
            selectedFilterStr = "Online"
        case 3:
            selectedFilterStr = "Created Events"
        default:
            selectedFilterStr = "All"
        }
                
        for event in eventViewModel.joinedEvents {
            // find events with matching id to joined book clubs
            if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
                if selectedFilterStr == "All" {
                    eventArr.append(event)
                } else if bookClub.meetingType == selectedFilterStr {
                    eventArr.append(event)
                } else if selectedFilter == 5 {
                    if bookClub.name == selectedClubName {
                        eventArr.append(event)
                        print("yeah")
                    }
                }
            }
        }

        return eventArr
    }
    
    // not working atm
    func createdEvents() -> [Event] {
        var eventArr: [Event] = []
        
        for event in eventViewModel.allEvents {
            if event.moderatorId == Auth.auth().currentUser?.uid {
                eventArr.append(event)
            }
        }
        
        return eventArr
    }
}

#Preview {
    EventsView()
}



//func getDayName(day: Int) -> String {
//    let calendar = Calendar(identifier: .gregorian)
//    let shortDays = calendar.shortWeekdaySymbols
//    return shortDays[day];
//}
