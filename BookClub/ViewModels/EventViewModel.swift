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
import MapKit

@MainActor
class EventViewModel: ObservableObject {
    @Published var allEvents: [Event] = []
    @Published var selectedClubEvents: [Event] = []  // when view club details
    
    @Published var searchResults: [MKMapItem] = []
    @Published var locationErrorPrompt: String = ""  // error message if invalid search query
    @Published var selectedLocation: MKMapItem?  // when tap location from search result list

    // add event to database
    func saveNewEvent(bookClubId: UUID, eventTitle: String, dateAndTime: Date, duration: Int, maxCapacity: Int, meetingLink: String, location: CLLocationCoordinate2D) async throws {
        // id of current user will be moderator
        guard let moderatorId = Auth.auth().currentUser?.uid else {
            print("couldn't get user ID to fetch details")
            return
        }
        
        let db = Firestore.firestore()
        // convert swift coords to Firebase GeoPoint
        let geopoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)

        let event = Event(moderatorId: moderatorId, bookClubId: bookClubId, eventTitle: eventTitle, dateAndTime: dateAndTime, duration: duration, maxCapacity: maxCapacity, meetingLink: !meetingLink.isEmpty ? meetingLink : nil, location: geopoint)

        do {
            try db.collection("Event").document(event.id.uuidString).setData(from: event)
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
            } else if meetingType == "In-Person" {
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
    
    // check whether location search query is valid before calling getSearchResults()
    func locationFieldValidation(query: String) async throws {
        self.searchResults = []

        if query.isEmpty {
            // reset results and error message
            locationErrorPrompt = ""
            return
        } else {
            // remove trailing whitespace
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // use to check string only has letters, numbers, hyphens, apostrophes and spaces
            let queryTest = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9\\-\\'\\’\\s]+$")
            
            // check the now trimmed query matches the regex pattern
            if queryTest.evaluate(with: trimmedQuery) {
                try await getSearchResults(query: trimmedQuery)
            } else {
                // invalid search query
                locationErrorPrompt = "No search results found. Please try again."
                return
            }
        }
    }
    
    func getSearchResults(query: String) async throws {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        
        if let response = try? await search.start() {
            let items = response.mapItems
            // reset search results each search
            self.searchResults = []
            
            // add up to 15 locations to results array
            for item in items {
                if self.searchResults.count < 15 {
                    self.searchResults.append(item)
                } else {
                    break
                }
            }
        } else {
            self.searchResults = []  // don't show any search results in list view
            locationErrorPrompt = "No search results found. Please try again."
        }
    }
    
    func getLocationName(location: GeoPoint) -> String {
        let geocoder = CLGeocoder()
        // convert geopoint to CLLocation
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        var locationName = ""

        if location.coordinate.latitude != 0 && location.coordinate.longitude != 0 {
            // get placemark name from CLLocation
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first?.name {
                    locationName = placemark
                    print(locationName)
                } else {
                    locationName = "Location unavailable"
                }
            }
        } else {
            locationName = "Online"
        }
        
        return locationName
    }
}
