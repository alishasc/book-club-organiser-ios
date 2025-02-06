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
    let name: String
    let email: String
    let favouriteGenres: [String]
    let location: String
}
