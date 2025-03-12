//
//  BookModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 19/02/2025.
//

import Foundation
import FirebaseFirestore

struct BookResponse: Codable {
    let items: [Book]
}

struct Book: Identifiable, Codable {
    let id: String  // actual id from json response
    let title: String
    let author: String
    let description: String
    let pageCount: Int
    let genre: String
    let cover: String
    let dateRead: Date?
    
    // forKey: ...
    enum CodingKeys: String, CodingKey {
        case id
        case volumeInfo  // nested object
        case title
        case authors  // nested array
        case description
        case pageCount
        case categories  // nested array containing genres
        case imageLinks  // nested object
        case thumbnail
    }
    
    // decode from API
    init(from decoder: any Decoder) throws {
        // outer container
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // get info from items array
        id = try container.decode(String.self, forKey: .id)
        
        // volumeInfo nested container
        let volumeInfoContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .volumeInfo)
        title = try volumeInfoContainer.decode(String.self, forKey: .title)
        description = try volumeInfoContainer.decodeIfPresent(String.self, forKey: .description) ?? "No description available"
        pageCount = try volumeInfoContainer.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        
        // authors nested array within volumeInfo
        let authorsArray = try volumeInfoContainer.decodeIfPresent([String].self, forKey: .authors) ?? ["Unknown author"]
        author = authorsArray.joined(separator: ", ")  // if multiple authors combine into one string
        
        let categoriesArray = try volumeInfoContainer.decodeIfPresent([String].self, forKey: .categories) ?? []
        genre = categoriesArray.first ?? "Unknown genre"

        if let imageLinksContainer = try? volumeInfoContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .imageLinks) {
            cover = try imageLinksContainer.decodeIfPresent(String.self, forKey: .thumbnail) ?? ""
        } else {
            cover = "Image not found"
        }
        
        // not coming from the API
        dateRead = nil
    }
    
    // to conform to Encodable - do opposite of decoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        var volumeInfoContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .volumeInfo)
        try volumeInfoContainer.encode(title, forKey: .title)
        try volumeInfoContainer.encode(description, forKey: .description)
        try volumeInfoContainer.encode(pageCount, forKey: .pageCount)
        
        // split string into separate authors and then save as array
        try volumeInfoContainer.encode(author.split(separator: ", ").map { String($0) }, forKey: .authors)
        try volumeInfoContainer.encode([genre], forKey: .categories)  // decoded from array so encode back to array
        
        var imageLinksContainer = volumeInfoContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .imageLinks)
        try imageLinksContainer.encode(cover, forKey: .thumbnail)
    }
}
