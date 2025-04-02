//
//  YourEventsListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct EventsRowView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    var bookClub: BookClub
    var event: Event
    var coverImage: UIImage
    var isModerator: Bool
    @State private var isAttendingEvent: Bool = false
    @State private var isEventSheetPresented: Bool = false  // event details pop-up
    @State private var locationName: String = "Loading..."
    
    var body: some View {
        ZStack {
            // for line along bottom - in background
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(eventViewModel.eventTagColor(isModerator: isModerator, meetingType: bookClub.meetingType))
                .frame(height: 120)
                .offset(y: 5)
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
            
            HStack {
                // image
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 120)
                    .padding(.trailing, 5)
                    .clipped()
                
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
                    Text("\(event.maxCapacity - event.attendeesCount) spaces left")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // checkmark and event type tag
                VStack {
                    Spacer()
                    Spacer()
                    // icon - make it toggle to checkmark.circle
                    // only show if user isn't the moderator
                    if !isModerator {
                        Image(systemName: isAttendingEvent ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(.accent)
                            .onTapGesture {
                                isAttendingEvent.toggle()
                                // call function to un/reserve space for event
                                Task {
                                    try await eventViewModel.attendEvent(isAttending: isAttendingEvent, eventId: event.id, bookClubId: bookClub.id)
                                }
                            }
                            .onAppear {
                                Task {
                                    // check whether user is already attending event - change ui
                                    isAttendingEvent = try await eventViewModel.isAttendingEvent(eventId: event.id)
                                }
                            }
                    }
                    Spacer()
                    
                    Text(eventViewModel.eventTagText(isModerator: isModerator, meetingType: bookClub.meetingType))
                        .font(.caption2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            eventViewModel.eventTagColor(isModerator: isModerator, meetingType: bookClub.meetingType)
                                .opacity(0.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .offset(x: -7, y: -7)
                }
            }
            .background(.white)
            .cornerRadius(10)
        }
        .frame(width: 350)
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
        }
        .onTapGesture {
            isEventSheetPresented = true
        }
        .sheet(isPresented: $isEventSheetPresented) {
            EventPopupView(bookClub: bookClub, event: event, coverImage: coverImage, isModerator: isModerator, isAttendingEvent: $isAttendingEvent)
        }
    }
}

//#Preview {
//    YourEventsListView(bookClubName: "Romance Book Club", eventTitle: "Starting new book!", location: "Waterstones Piccadilly", dateAndTime: Date(), spacesLeft: 5, isModerator: true, meetingType: "Online")
//}
