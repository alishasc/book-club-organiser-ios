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
    var coverImage: UIImage
    var event: Event
    var isModerator: Bool
    
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
                    .frame(width: 110, height: 120)
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
                    Text(event.location ?? "Online")
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
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.accent)
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
        .padding(.horizontal, 2)  // to show drop shadow on edges
    }
}

//#Preview {
//    YourEventsListView(bookClubName: "Romance Book Club", eventTitle: "Starting new book!", location: "Waterstones Piccadilly", dateAndTime: Date(), spacesLeft: 5, isModerator: true, meetingType: "Online")
//}
