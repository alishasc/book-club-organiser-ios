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

struct ClubMembersModel: Identifiable, Codable {
    var id: UUID = UUID()
    let members: [String]
}
