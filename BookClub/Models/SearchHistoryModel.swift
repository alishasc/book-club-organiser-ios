//
//  SearchHistoryModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 28/04/2025.
//

import Foundation

struct SearchHistory: Identifiable, Codable {
    var id: UUID = UUID()
    let clubName: String
    let clubGenre: String
}
