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
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()

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
            fetchCurrentWeek()
        }
    }

    func isURLValid(url: String) -> Bool {
        // MARK: ref - https://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
        let urlHttpRegex = "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
        // url without HTTP protocol
        let urlRegex = "[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
        
        if NSPredicate(format: "SELF MATCHES %@", urlHttpRegex).evaluate(with: url) {
            return NSPredicate(format: "SELF MATCHES %@", urlHttpRegex).evaluate(with: url)
        } else {
            return NSPredicate(format: "SELF MATCHES %@", urlRegex).evaluate(with: url)
        }
    }
    
    // add event to database
    func saveNewEvent(bookClubId: UUID, eventTitle: String, dateAndTime: Date, duration: Int, maxCapacity: Int, meetingLink: String, location: CLLocationCoordinate2D) async throws {
        // id of current user will be moderator
        guard let moderatorId = Auth.auth().currentUser?.uid else {
            print("couldn't get user ID to fetch details")
            return
        }
        
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
    
    func updateEventDetails(event: Event, title: String, dateAndTime: Date, duration: Int, meetingLink: String, location: GeoPoint?) async throws {        
        var updatedData: [String: Any] = [:]

        if title != event.eventTitle {
            updatedData["eventTitle"] = title
        }
        if dateAndTime != event.dateAndTime {
            updatedData["dateAndTime"] = dateAndTime
        }
        if duration != event.duration {
            updatedData["duration"] = duration
        }
        if !meetingLink.isEmpty {
            if meetingLink != event.meetingLink {
                updatedData["meetingLink"] = meetingLink
            }
        }

        if let originalLocation = event.location,
           let newLocation = location {
            if !originalLocation.latitude.isEqual(to: newLocation.latitude) || !originalLocation.longitude.isEqual(to: newLocation.longitude) {
                updatedData["location"] = location
            }
        }

        do {
            try await db.collection("Event").document(event.id.uuidString).setData(updatedData, merge: true)
        } catch {
            print("failed to save new event details: \(error.localizedDescription)")
        }
        
        self.selectedLocation = nil
        self.searchResults = []
        try await fetchEvents()
    }

    func deleteEvent(eventId: UUID) async throws {
        do {
            let doc = try await db.collection("Event").document(eventId.uuidString).getDocument()
            let event = try doc.data(as: Event.self)
            // delete from db
            try await doc.reference.delete()
            
            self.allEvents.removeAll { $0.id == event.id }  // update ui
            
            // remove EventAttendees linked to the event
            let eventAttendeeDocs = try await db.collection("EventAttendees").whereField("eventId", isEqualTo: eventId.uuidString).getDocuments()
            for doc in eventAttendeeDocs.documents {
                try await doc.reference.delete()
            }
        } catch {
            print("Error deleting event: \(error.localizedDescription)")
        }
    }
    
    // fetches all events from database
    func fetchEvents() async throws {
        // empty arrays when fetch information again - no duplicates
        self.allEvents.removeAll()
        self.joinedEvents.removeAll()
        
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
    
    func formatDurationToInt(minutes: String) -> Int {
        switch minutes {
        case "30 minutes":
            return 30
        case "1 hour":
            return 60
        case "1 hour 30 minutes":
            return 90
        case "2 hours":
            return 120
        default:
            return 0
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
        // logged in user's id
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // if icon toggled to true - filled checkmark icon
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
                print("Failed to save event space: \(error.localizedDescription)")
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
                print("Failed to unreserve event space: \(error.localizedDescription)")
            }
        }
        
        self.allEvents.removeAll(where: { $0.id == event.id })
        let document = try await db.collection("Event").document(event.id.uuidString).getDocument()
        let event = try document.data(as: Event.self)
        self.allEvents.append(event)
    }
    
    // check if user is attending shown events. passed as var to change ui
    func isAttendingEvent(eventId: UUID) async throws -> Bool {
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

    func getModeratorAndAttendeePics(bookClubId: UUID, eventId: UUID, moderatorId: String, authViewModel: AuthViewModel) async throws {
        self.eventAttendeePics.removeAll()
        
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
    
    // MARK: ref: https://www.youtube.com/watch?v=nKHrsrmA4lM
    @Published var currentWeek: [Date] = []
    @Published var currentDay: Date?
    @Published var filteredEvents: [Event]?
    
    func fetchCurrentWeek() {
        let today = Date()
        let calendar = Calendar.current
        
        let week = calendar.dateInterval(of: .weekOfYear, for: today)
        guard let firstWeekDay = week?.start else { return }
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    func isToday(date: Date) -> Bool {
        return Calendar.current.isDate(currentDay ?? Date.distantPast, inSameDayAs: date)
    }
    
    func hasEventsToday(date: Date) -> Bool {
        let createdEvents = allEvents.filter({ $0.moderatorId == Auth.auth().currentUser?.uid })
        let combinedEvents = self.joinedEvents + createdEvents
        
        return combinedEvents.contains {
            Calendar.current.isDate($0.dateAndTime, inSameDayAs: date)
        }
    }
    
    // colors of the dots on the date filter - events page
    func eventColors(date: Date) -> [Color] {
        let createdEvents = allEvents.filter({ $0.moderatorId == Auth.auth().currentUser?.uid })
        let combinedEvents = self.joinedEvents + createdEvents
        
        var eventTypes: Set<Color> = []  // only one of each colour will be added
        
        for _ in combinedEvents {
            // created events - pink
            if combinedEvents.contains(where: { $0.moderatorId == Auth.auth().currentUser?.uid && Calendar.current.isDate($0.dateAndTime, inSameDayAs: date)}) {
                eventTypes.insert(.customPink)
                continue
            }
            // online events - green
            if combinedEvents.contains(where: { $0.meetingLink != nil && Calendar.current.isDate($0.dateAndTime, inSameDayAs: date)}) {
                eventTypes.insert(.customGreen)
            }
            // in-person events - yellow
            if combinedEvents.contains(where: { $0.location != GeoPoint(latitude: 0, longitude: 0) && Calendar.current.isDate($0.dateAndTime, inSameDayAs: date) }) {
                eventTypes.insert(.customYellow)
            }
        }

        return Array(eventTypes)
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

        if self.currentDay != nil {
            for event in filteredEventArr {
                if !Calendar.current.isDate(event.0.dateAndTime, inSameDayAs: self.currentDay ?? Date.distantPast) {
                    filteredEventArr.removeAll(where: { $0.0.id == event.0.id })
                }
            }
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
        
        if self.currentDay != nil {
            for event in filteredEventArr {
                if !Calendar.current.isDate(event.0.dateAndTime, inSameDayAs: self.currentDay ?? Date.distantPast) {
                    filteredEventArr.removeAll(where: { $0.0.id == event.0.id })
                }
            }
        }
        
        return filteredEventArr.sorted(by: { $0.0.dateAndTime < $1.0.dateAndTime })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //    func attendingMemberCount(eventId: UUID) async throws {
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
}
