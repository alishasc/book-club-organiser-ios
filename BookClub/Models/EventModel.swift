//
//  EventModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 03/03/2025.
//

import Foundation
import FirebaseFirestore

struct Event: Identifiable, Codable {
    var id: UUID = UUID()
    var moderatorId: String  // id of who's making the event
    var bookClubId: UUID  // book club event is for
    var eventTitle: String
    var dateAndTime: Date
    var duration: Int
    var maxCapacity: Int
    var attendeesCount: Int = 0
    var eventStatus: String = "upcoming"
    var meetingLink: String?
    var location: String?
}
