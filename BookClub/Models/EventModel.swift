//
//  EventModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 03/03/2025.
//

import Foundation
import FirebaseFirestore
import MapKit

struct Event: Identifiable, Codable {
    var id: UUID = UUID()
    var moderatorId: String  // id of who's making the event
    var bookClubId: UUID  // book club the event is for
    var eventTitle: String
    var dateAndTime: Date
    var duration: Int
    var maxCapacity: Int
    var attendeesCount: Int = 0
    var eventStatus: String = "upcoming"  // alter this somewhere
    var meetingLink: String?  // if online
    var location: GeoPoint?
}
