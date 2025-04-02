//
//  EventAttendees.swift
//  BookClub
//
//  Created by Alisha Carrington on 02/04/2025.
//

import Foundation
import FirebaseFirestore

struct EventAttendee: Identifiable, Codable {
    var id: UUID = UUID()
    let eventId: UUID
    let bookClubId: UUID
    let userId: String
}
