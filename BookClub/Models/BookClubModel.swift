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
    let moderatorId: String
    let moderatorName: String
    let coverImageURL: String  // path to get image from storage
    let description: String
    let genre: String
    let meetingType: String
    let isPublic: Bool
    let creationDate: Date
    // books
    let currentBookId: String?
    let booksRead: [String]?  // change to dict?
    
    enum CodingKeys: String, CodingKey {
        case id, name, moderatorId, moderatorName, coverImageURL, description, genre, meetingType, isPublic, creationDate, currentBookId, booksRead
    }
}
