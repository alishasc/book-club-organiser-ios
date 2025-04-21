//
//  UserModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var favouriteGenres: [String]
    var location: String
    var joinedClubs: [String]
    var profilePictureURL: String 
}
