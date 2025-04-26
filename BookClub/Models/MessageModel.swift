//
//  MessageModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 18/04/2025.
//

import Foundation
import Firebase

struct Message: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let fromId: String
    let toId: String
    let text: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
    }
}

struct RecentMessage: Identifiable, Codable {
    var id: String { documentId }
        
    let documentId: String
    let fromId: String
    let toId: String
    let text: String
    let userName: String
    let profilePictureURL: String // of recipient
    let timestamp: Timestamp
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.userName = data["userName"] as? String ?? ""
        self.profilePictureURL = data["profilePictureURL"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
    }
}
