//
//  EventViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 03/03/2025.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import MapKit
import FirebaseStorage

@MainActor
class EventViewModel: ObservableObject {
    @Published var allEvents: [Event] = []
    @Published var joinedEvents: [Event] = []
    
    @Published var searchResults: [MKMapItem] = []
    @Published var locationErrorPrompt: String = ""  // error message if invalid search query
    @Published var selectedLocation: MKMapItem?  // when tap location from search result list
    
    @Published var eventAttendeePics: [UIImage] = []
    @Published var moderatorPic: UIImage = UIImage()
    
    init() {
        Task {
            try await fetchEvents()
        }
    }
    
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
            self.allEvents.append(event)
        } catch {
            print("failed to save new event details: \(error.localizedDescription)")
        }
    }
    
    // fetches all events from database
    func fetchEvents() async throws {
        // empty arrays when fetch information again - no duplicates
        self.allEvents.removeAll()
        self.joinedEvents.removeAll()
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("couldn't get user ID to fetch details")
            return
        }
        
        do {
            let querySnapshot = try await db.collection("Event").order(by: "dateAndTime").getDocuments()
            for document in querySnapshot.documents {
                let event = try document.data(as: Event.self)
                self.allEvents.append(event)
                
                // filter joined clubs into separate array
                let querySnapshot = try await db.collection("EventAttendees")
                    .whereField("eventId", isEqualTo: event.id.uuidString)
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                // doc exists = user has reserved space for event
                if querySnapshot.documents.first != nil {
                    // add to joinedEvents array
                    self.joinedEvents.append(event)
                }
            }
        } catch {
            print("error getting event documents: \(error.localizedDescription)")
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
    
    // for showing location address in EventsRowView
    func getLocationPlacemark(location: GeoPoint, completionHandler: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        // convert GeoPoint into CLLocation
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        // get placemark info for that location
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                let locationPlacemark = placemarks?[0]
                completionHandler(locationPlacemark)
            } else {
                completionHandler(nil)
            }
        })
    }

    // update db when join/leave event
    func attendEvent(isAttending: Bool, event: Event, bookClub: BookClub) async throws {
        let db = Firestore.firestore()
        // logged in user's id
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // if icon toggled to true
        if isAttending {
            // save attendee info to db
            do {
                let eventAttendee = EventAttendee(eventId: event.id, bookClubId: bookClub.id, userId: userId)
                try db.collection("EventAttendees").document(eventAttendee.id.uuidString).setData(from: eventAttendee)
                try await db.collection("Event").document(event.id.uuidString).updateData([
                    // add one to attendeesCount
                    "attendeesCount": FieldValue.increment(Int64(1))
                ])
                
                let document = try await db.collection("Event").document(event.id.uuidString).getDocument()
                let updatedEvent = try document.data(as: Event.self)
                // update joinedEvents array
                self.joinedEvents.append(updatedEvent)
            } catch {
                print("failed to save event space: \(error.localizedDescription)")
            }
        }
        else {
            // remove attendee info from db
            do {
                // look for doc with matching eventId and userId
                let querySnapshot = try await db.collection("EventAttendees")
                    .whereField("eventId", isEqualTo: event.id.uuidString)
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                
                if let document = querySnapshot.documents.first {
                    let eventAttendee = try document.data(as: EventAttendee.self)
                    // delete doc from db
                    try await db.collection("EventAttendees").document(eventAttendee.id.uuidString).delete()
                    try await db.collection("Event").document(event.id.uuidString).updateData([
                        // remove one from attendeesCount
                        "attendeesCount": FieldValue.increment(Int64(-1))
                    ])
                }
                
                // update joinedEvents array
                self.joinedEvents.removeAll(where: { event.id == $0.id })
            } catch {
                print("failed to unreserve event space: \(error.localizedDescription)")
            }
        }
        
        self.allEvents.removeAll(where: { $0.id == event.id })
        let document = try await db.collection("Event").document(event.id.uuidString).getDocument()
        let event = try document.data(as: Event.self)
        self.allEvents.append(event)
    }
    
    // check if user is attending shown events. passed as var to change ui
    func isAttendingEvent(eventId: UUID) async throws -> Bool {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("couldn't get user ID to fetch details")
            return false
        }
        
        // look for doc with matching eventId and userId
        let querySnapshot = try await db.collection("EventAttendees")
            .whereField("eventId", isEqualTo: eventId.uuidString)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        // doc exists = user has reserved space for event
        if querySnapshot.documents.first != nil {
            return true
        } else {
            return false
        }
    }
    
    // events page
    func filteredUpcomingEvents(selectedFilter: Int, bookClubViewModel: BookClubViewModel, selectedClubName: String?) -> [(event: Event, bookClub: BookClub)] {
        var filteredEventArr: [(Event, BookClub)] = []
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        switch selectedFilter {
        case 0:
            // all events
            for event in joinedEvents {
                // find events with matching id to joined book clubs
                if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
                    filteredEventArr.append((event, bookClub))
                }
            }
            // add created events - search for events where logged in user is the moderator
            for event in allEvents.filter({ $0.moderatorId == userId }) {
                // search all clubs with matching bookClubId
                if let bookClub = bookClubViewModel.allClubs.first(where: { $0.id == event.bookClubId }) {
                    filteredEventArr.append((event, bookClub))
                }
            }
        case 1:
            // in-person events
            for event in joinedEvents {
                if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
                    if bookClub.meetingType == "In-Person" {
                        filteredEventArr.append((event, bookClub))
                    }
                }
            }
        case 2:
            // online events
            for event in joinedEvents {
                if let bookClub = bookClubViewModel.joinedClubs.first(where: { $0.id == event.bookClubId }) {
                    if bookClub.meetingType == "Online" {
                        filteredEventArr.append((event, bookClub))
                    }
                }
            }
        case 3:
            // created events
            for event in allEvents.filter({ $0.moderatorId == userId }) {
                // search all clubs with matching bookClubId
                if let bookClub = bookClubViewModel.allClubs.first(where: { $0.id == event.bookClubId }) {
                    filteredEventArr.append((event, bookClub))
                }
            }
        default:
            break
        }
        
        if let selectedClubName {
            // only show club selected
            filteredEventArr = filteredEventArr.filter { $0.1.name == selectedClubName }
        }
        
        return filteredEventArr.sorted(by: { $0.0.dateAndTime < $1.0.dateAndTime })
    }
    
    // events page
    func filteredDiscoverEvents(selectedFilter: Int, bookClubViewModel: BookClubViewModel, selectedClubName: String?) -> [(event: Event, bookClub: BookClub)] {
        var filteredEventArr: [(Event, BookClub)] = []
        
        switch selectedFilter {
        case 0:  // all events
            // get joined book clubs
            for bookClub in bookClubViewModel.joinedClubs {
                // find events for the clubs joined
                for event in allEvents.filter({ $0.bookClubId.uuidString == bookClub.id.uuidString }) {
                    // filter out events already joined
                    if !joinedEvents.contains(where: { $0.id.uuidString == event.id.uuidString }) {
                        filteredEventArr.append((event, bookClub))
                    }
                }
            }
        case 1:  // in-person events
            for bookClub in bookClubViewModel.joinedClubs {
                // find events for the clubs joined
                for event in allEvents.filter({ $0.bookClubId.uuidString == bookClub.id.uuidString }) {
                    // filter out events already joined
                    if !joinedEvents.contains(where: { $0.id.uuidString == event.id.uuidString }) {
                        if bookClub.meetingType == "In-Person" {
                            filteredEventArr.append((event, bookClub))
                        }
                    }
                }
            }
        case 2:  // online events
            for bookClub in bookClubViewModel.joinedClubs {
                // find events for the clubs joined
                for event in allEvents.filter({ $0.bookClubId.uuidString == bookClub.id.uuidString }) {
                    // filter out events already joined
                    if !joinedEvents.contains(where: { $0.id.uuidString == event.id.uuidString }) {
                        if bookClub.meetingType == "Online" {
                            filteredEventArr.append((event, bookClub))
                        }
                    }
                }
            }
        default:
            break
        }
        
        if let selectedClubName {
            // only show club selected
            filteredEventArr = filteredEventArr.filter { $0.1.name == selectedClubName }
        }
        
        return filteredEventArr.sorted(by: { $0.0.dateAndTime < $1.0.dateAndTime })
    }
    
    
    func getModeratorAndAttendeePics(bookClubId: UUID, eventId: UUID, moderatorId: String, authViewModel: AuthViewModel) async throws {
        self.eventAttendeePics.removeAll()
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        
        do {
            // get attendee pics
            let querySnapshot = try await db.collection("EventAttendees").whereField("eventId", isEqualTo: eventId.uuidString).getDocuments()
            
            for document in querySnapshot.documents {
                let eventAttendee = try document.data(as: EventAttendee.self)
                
                // get profile picture from User collection
                let user = try await db.collection("User").document(eventAttendee.userId).getDocument(as: User.self)
                let imageRef = storageRef.child(user.profilePictureURL)
                
                // get the image
                imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(
                            "error occured fetching image: \(error.localizedDescription)"
                        )
                    } else if let data = data {
                        let image = UIImage(data: data)
                        // save user id and image to dictionary
                        self.eventAttendeePics.append(image ?? UIImage())
                    }
                }
            }
            
            // get moderator pic
            if moderatorId != Auth.auth().currentUser?.uid {
                let document = try await db.collection("User").document(moderatorId).getDocument()
                let moderator = try document.data(as: User.self)
                let imageRef = storageRef.child(moderator.profilePictureURL)
                
                // get the image
                imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(
                            "error occured fetching image: \(error.localizedDescription)"
                        )
                    } else if let data = data {
                        let image = UIImage(data: data)
                        // save user id and image to dictionary
                        self.moderatorPic = image ?? UIImage()
                    }
                }
            } else {
                self.moderatorPic = authViewModel.profilePic ?? UIImage()
            }
        } catch {
            print("Error fetching book club member pictures: \(error.localizedDescription)")
        }
    }
    
    //    func attendingMemberCount(eventId: UUID) async throws {
    //        let db = Firestore.firestore()
    //
    //        let querySnapshot = try await db.collection("EventAttendees").whereField("eventId", isEqualTo: eventId.uuidString).getDocuments()
    //        for _ in querySnapshot.documents {
    //            if querySnapshot.documents.count > 0 {
    //                self.totalAttending[eventId] = querySnapshot.documents.count
    //            } else {
    //                self.totalAttending.removeValue(forKey: eventId)
    //            }
    //        }
    //    }
    
    
    
    
    
    
    
    
    
    //    func checkIsAttending(bookClub: BookClub) -> Bool {
    //        let db = Firestore.firestore()
    //        guard let userId = Auth.auth().currentUser?.uid else {
    //            print("couldn't get user ID to fetch details")
    //            return false
    //        }
    //
    //        return joinedClubs.contains(where: { $0.id.uuidString == bookClub.id.uuidString })
    //        return true
    //    }
    
    
    //    func fetchAttendingEvents() async throws -> [Event] {
    //        let db = Firestore.firestore()
    //        var events: [Event] = []
    //
    //        guard let userId = Auth.auth().currentUser?.uid else {
    //            print("couldn't get user ID to fetch details")
    //            return []
    //        }
    //
    //        do {
    //            let querySnapshot = try await db.collection("EventAttendees")
    //                .whereField("userId", isEqualTo: userId).getDocuments()
    //
    //            for document in querySnapshot.documents {
    //                let eventAttendee = try document.data(as: EventAttendee.self)
    //
    //                let querySnapshot2 = try await db.collection("Event").whereField("eventId", isEqualTo: eventAttendee.eventId.uuidString).getDocuments()
    //                for document in querySnapshot2.documents {
    //                    let event = try document.data(as: Event.self)
    //                    events.append(event)
    //                }
    //            }
    //        } catch {
    //            print("error fetching events attending: \(error.localizedDescription)")
    //        }
    //
    //        print("events: \(events)")
    //
    //        return events
    //    }
    
    
    // fetch events only for selected club
    //    func fetchSelectedClubEvents(bookClubId: UUID) async throws {
    //        print("fetch selected club events")
    //        self.selectedClubEvents.removeAll()
    //
    //        let db = Firestore.firestore()
    //
    //        do {
    //            let querySnapshot = try await db.collection("Event").whereField("bookClubId", isEqualTo: bookClubId.uuidString).getDocuments()
    //            for document in querySnapshot.documents {
    //                let event = try document.data(as: Event.self)
    //                self.selectedClubEvents.append(event)
    //            }
    //        } catch {
    //            print("error getting events: \(error.localizedDescription)")
    //        }
    //    }
}
