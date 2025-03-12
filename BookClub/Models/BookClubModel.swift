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
    let moderatorId: String  // or userId
    let coverImageURL: String  // path to get image from storage
    var uiImage: UIImage? = nil  // uiimage fetched from storage
    let description: String
    let genre: String
    let meetingType: String
    let isPublic: Bool
    let creationDate: Date
    //    let members: [String]  // array of userId string - or map??
    
    enum CodingKeys: String, CodingKey {
        case id, name, moderatorId, coverImageURL, description, genre, meetingType, isPublic, creationDate
    }
}
