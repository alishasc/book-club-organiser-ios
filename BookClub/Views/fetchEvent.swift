//
//  fetchEvent.swift
//  BookClub
//
//  Created by Alisha Carrington on 03/03/2025.
//

import SwiftUI

struct fetchEvent: View {
    @StateObject var eventViewModel: EventViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(eventViewModel.fetchedEvents) { event in
                    Text("id: \(event.id)")
                    Text("moderator id: \(event.moderatorId)")
                    Text("title: \(event.eventTitle)")
                    Text("date: \(event.dateAndTime)")
                    Text("duration: \(event.duration)")
                    Text("capacity: \(event.maxCapacity)")
                    Text("attendees: \(event.attendeesCount)")
                    Text("event status: \(event.eventStatus)")
                    Text("meeting link: \(event.meetingLink ?? "no meeting link")")
                    Text("address: \(event.location ?? "no address")")
                }
            }
        }
        .padding()
        .onAppear {
            // fetch event
            Task {
                try await eventViewModel.fetchEvents()
            }
        }
    }
}

#Preview {
    fetchEvent(eventViewModel: EventViewModel())
}
