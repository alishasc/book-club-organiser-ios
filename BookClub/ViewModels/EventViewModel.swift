//
//  EventViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 03/03/2025.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@MainActor
class EventViewModel: ObservableObject {
    @Published var allEvents: [Event] = []
    @Published var selectedClubEvents: [Event] = []  // when view club details
    
//    init() {
//        Task {
//            try await fetchEvents()
//        }
//    }
    
    // add event to database
    func saveNewEvent(bookClubId: UUID, eventTitle: String, dateAndTime: Date, duration: Int, maxCapacity: Int, meetingLink: String, location: String) async throws {
        // id of current user will be moderator
        guard let moderatorId = Auth.auth().currentUser?.uid else {
            print("couldn't get the id to fetch details")
            return
        }
        
        let db = Firestore.firestore()

        let event = Event(moderatorId: moderatorId, bookClubId: bookClubId, eventTitle: eventTitle, dateAndTime: dateAndTime, duration: duration, maxCapacity: maxCapacity, meetingLink: !meetingLink.isEmpty ? meetingLink : nil, location: !location.isEmpty ? location : nil)

        do {
            try db.collection("Event").document(event.id.uuidString).setData(from: event)
            print("saved new event details successfully")
        } catch {
            print("failed to save new event details: \(error.localizedDescription)")
        }
    }
    
    // fetches all events from database
    func fetchEvents() async throws {
        self.allEvents.removeAll()  // empty array when try fetch information again - so doesn't duplicate
        
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("Event").getDocuments()
            for document in querySnapshot.documents {
                let event = try document.data(as: Event.self)
                self.allEvents.append(event)
            }
        } catch {
            print("error getting event documents: \(error.localizedDescription)")
        }
    }
    
    // fetch events only for selected club
    func fetchSelectedClubEvents(bookClubId: UUID) async throws {
        print("fetch selected club events")
        self.selectedClubEvents.removeAll()
        
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("Event").whereField("bookClubId", isEqualTo: bookClubId.uuidString).getDocuments()
            for document in querySnapshot.documents {
                let event = try document.data(as: Event.self)
                self.selectedClubEvents.append(event)
            }
        } catch {
            print("error getting events: \(error.localizedDescription)")
        }
    }

    // change color on event cards
    func eventTagColor(isModerator: Bool, meetingType: String) -> Color {
        var color: Color = .black
        
        if isModerator {
            color = .customPink
        } else {
            if meetingType == "Online" {
                color = .customGreen
            } else if meetingType == "In=Person" {
                color = .customYellow
            }
        }
        
        return color
    }
    
    // change tag text on event cards
    func eventTagText(isModerator: Bool, meetingType: String) -> String {
        var text: String = ""
        
        if isModerator {
            text = "Created"
        } else {
            text = meetingType
        }
        
        return text
    }
}
