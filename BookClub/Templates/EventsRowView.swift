//
//  YourEventsListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct EventsRowView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    var bookClub: BookClub
    var event: Event
    var coverImage: UIImage
    var isModerator: Bool
    @State private var isAttendingEvent: Bool = false  // checkmark icon ui
    @State private var isEventSheetPresented: Bool = false  // event details pop-up
    @State private var locationName: String = "Loading..."
    @State private var spacesLeft: Int = 0
    
    var body: some View {
        ZStack {
            // for line along bottom - in background
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(eventViewModel.eventTagColor(isModerator: isModerator, meetingType: bookClub.meetingType))
                .frame(height: 110)
                .offset(y: 4)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: -2)  // top shadow
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)  // bottom shadow
            
            HStack {
                // image
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 110)
                    .clipped()
                    .padding(.trailing, 5)
                
                // text event info
                VStack(alignment: .leading) {
                    Text(bookClub.name)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text(event.eventTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text(locationName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(ViewTemplates.dateFormatter(dateAndTime: event.dateAndTime))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if spacesLeft > 0 {
                        Text("\(spacesLeft) spaces left")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        // change text if event is full
                        Text("Full")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // checkmark and event type tag
                VStack(alignment: .trailing) {
                    Spacer()
                    Spacer()
                    // only show icons if the user isn't the moderator and is part of the club
                    if !isModerator && bookClubViewModel.checkIsMember(bookClub: bookClub) {
                        
                        // MARK: no spaces left for event -
                        // if attending the event - keep filled checkmark visible
                        // if not attending the event - hide checkmark icon completely
                        
                        if eventCheckmarkIcon(isAttending: isAttendingEvent, hasSpacesLeft: spacesLeft > 0) != "" {
                            Image(systemName: eventCheckmarkIcon(isAttending: isAttendingEvent, hasSpacesLeft: spacesLeft > 0))
                                .font(.system(size: 25))
                                .foregroundStyle(.accent)
                                .padding(.trailing, 12)
                                .onTapGesture {
                                    isAttendingEvent.toggle()
                                    // call function to un/reserve space for event
                                    Task {
                                        try await eventViewModel.attendEvent(isAttending: isAttendingEvent, event: event, bookClub: bookClub)
                                    }
                                }
                                .onAppear {
                                    Task {
                                        // check whether user is already attending event - sets ui
                                        isAttendingEvent = try await eventViewModel.isAttendingEvent(eventId: event.id)
                                    }
                                }
                        }
                    }
                    
                    Spacer()
                    
                    Text(eventViewModel.eventTagText(isModerator: isModerator, meetingType: bookClub.meetingType))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            eventViewModel.eventTagColor(isModerator: isModerator, meetingType: bookClub.meetingType)
                                .opacity(0.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .offset(x: -5, y: -5)
                }
            }
            .background(.white)
            .cornerRadius(10)
        }
        .onAppear {
            // to show event address
            if event.meetingLink != nil {
                locationName = "Online"
            } else if let geoPoint = event.location {
                eventViewModel.getLocationPlacemark(location: geoPoint, completionHandler: { placemark in
                    // get name from placemark
                    if let name = placemark?.name {
                        self.locationName = name
                    }
                })
            }
            
            self.spacesLeft = event.maxCapacity - event.attendeesCount
        }
        .onTapGesture {
            // can only see extra details if member of the club or moderator
            if bookClubViewModel.checkIsMember(bookClub: bookClub) || isModerator {
                isEventSheetPresented = true
            }
        }
        .sheet(isPresented: $isEventSheetPresented) {
            NavigationStack {
                EventPopupHostView(bookClub: bookClub, event: event, coverImage: coverImage, isModerator: isModerator, isAttendingEvent: $isAttendingEvent, spacesLeft: $spacesLeft)
            }
        }
    }
}

func eventCheckmarkIcon(isAttending: Bool, hasSpacesLeft: Bool) -> String {
    if isAttending {
        return "checkmark.circle.fill"
    } else if !isAttending && hasSpacesLeft {
        // not attending and has spaces left
        return "checkmark.circle"
    } else {
        // not attending and no spaces left
        return ""
    }
}

// "checkmark.circle.fill" : "checkmark.circle"

//#Preview {
//    EventsRowView(bookClub: BookClub(name: "", moderatorId: "", moderatorName: "", coverImageURL: "", description: "", genre: "", meetingType: "Online", isPublic: true, creationDate: Date.now, currentBookId: "", booksRead: []), event: Event(moderatorId: "", bookClubId: UUID(), eventTitle: "event title", dateAndTime: Date.now, duration: 30, maxCapacity: 10), coverImage: UIImage(named: "banner") ?? UIImage(), isModerator: false)
//}
