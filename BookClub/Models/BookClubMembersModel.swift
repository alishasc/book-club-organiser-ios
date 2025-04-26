//
//  ClubMembersModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 28/03/2025.
//

// track what users are in each club

import Foundation
import Foundation
import FirebaseFirestore

struct BookClubMembers: Identifiable, Codable {
    var id: UUID = UUID()
    let bookClubId: UUID
    let bookClubName: String
    let userId: String
    let userName: String
    let profilePictureURL: String
}
