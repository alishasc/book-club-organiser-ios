//
//  MessageViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 17/04/2025.
//

import Foundation
import FirebaseAuth
import Firebase

@MainActor
class MessageViewModel: ObservableObject {
    @Published var chatText: String = ""
    @Published var chatMessages: [Message] = []
    @Published var recentMessages: [RecentMessage] = []
    let chatUser: BookClubMembers?  // recipient of message
    
    @Published var count: Int = 0
    
    init(chatUser: BookClubMembers?) {
        self.chatUser = chatUser
        fetchMessages()
        fetchRecentMessages()
    }
    
    private func fetchRecentMessages() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }  // current user
        
        db.collection("RecentMessages")
            .document(uid)
            .collection("Messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to listen for recent messages: \(error.localizedDescription)")
                    return
                }
                
                // get new recent message docs in real-time
                querySnapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID
                    
                    // get index of last doc/recent message and remove it from the array
                    if let index = self.recentMessages.firstIndex(where: { recentMessage in
                        return recentMessage.documentId == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    // add latest recent message to the array - insert at beginning of list
                    self.recentMessages.insert(RecentMessage(documentId: docId, data: change.document.data()), at: 0)
                }
            }
    }
    
    private func fetchMessages() {
        let db = Firestore.firestore()
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.userId else { return }
        
        db.collection("Messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to listen for messages: \(error.localizedDescription)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(Message(documentId: change.document.documentID, data: data))
                    }
                }
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func handleSend() {
        let db = Firestore.firestore()
        print(chatText)
        
        // who's sending the message - logged in user
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        // recipient of message
        guard let toId = chatUser?.userId else { return }
        
        let messageData = ["fromId": fromId, "toId": toId, "text": self.chatText, "timestamp": Timestamp()] as [String : Any]
        
        // doc for current user
        let document = db
            .collection("Messages")  // top-level
            .document(fromId)
            .collection(toId)  // subcollection
            .document()
        
        document.setData(messageData) { error in
            if let error = error {
                print("Failed to save message to db: \(error.localizedDescription)")
                return
            }
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = db
            .collection("Messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print("Failed to save message to db: \(error.localizedDescription)")
                return
            }
        }
    }
    
    // save all messages inside the main Messages page - new messages will override existing db docs
    private func persistRecentMessage() {
        let db = Firestore.firestore()
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.userId else { return }

        let document = db
            .collection("RecentMessages")
            .document(fromId)  // owner of recent message owned by current uid
            .collection("Messages")
            .document(toId)  // person sending message to
        
        let data = [
            "timestamp": Timestamp(),  // to sort order of recent messages
            "text": self.chatText,
            "fromId": fromId,
            "toId": toId,
            "profileImageURL": chatUser?.profilePictureURL ?? "",
            "userName": chatUser?.userName ?? ""
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                print("Failed to save recent message: \(error.localizedDescription)")
                return
            }
        }
        
        // repeated to dict for recipient of the message
        let recipientMessageDocument = db
            .collection("RecentMessages")
            .document(toId)
            .collection("Messages")
            .document(fromId)
        
        recipientMessageDocument.setData(data) { error in
            if let error = error {
                print("Failed to save message to db: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func getTimeDifference(timestamp: Timestamp) -> String {
        // get difference between current date and timestamp
        let currentDate = Date.now
        let timestamp = timestamp.dateValue()
            
        let difference = Calendar.current.dateComponents([.day, .hour, .minute], from: timestamp, to: currentDate)
        var differenceStr: String = ""
        
        if let day = difference.day, day > 0 {
            differenceStr = "\(day)d ago"
        } else if let hour = difference.hour, hour > 0 {
            differenceStr = "\(hour)h ago"
        } else if let minute = difference.minute {
            differenceStr = "\(minute)m ago"
        }

        return differenceStr
    }
}
