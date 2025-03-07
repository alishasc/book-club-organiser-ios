//
//  BookClubModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 10/02/2025.
//

import Foundation
import FirebaseFirestore

struct BookClub: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let moderatorId: String  // userId string
    let coverImage: String?
//    let members: [String]  // array of userId string - or map??
    let description: String
    let genre: String
    let meetingType: String
    let isPublic: Bool
    let creationDate: Date
}
