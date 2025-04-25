//
//  BookClubViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 12/02/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@MainActor
class BookClubViewModel: ObservableObject {
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    @Published var allClubs: [BookClub] = []
    @Published var createdClubs: [BookClub] = []
    @Published var joinedClubs: [BookClub] = []
    @Published var bookClub: BookClub?  // updated when tap club in clubs list
    @Published var coverImages: [UUID: UIImage] = [:]  // bookClubId : UIImage
    
    @Published var messageUsers: [BookClubMembers] = []
    @Published var memberPics: [String: UIImage] = [:]  // userId : UIImage
        
    @Published var clubMemberPics: [UIImage] = []
    @Published var moderatorInfo: [String: UIImage] = [:]  // name : profile picture
    
    
    // options for creating new club
    let genreChoices: [String] = [
        "Art & Design",
        "Biography",
        "Business",
        "Children's Fiction",
        "Classics",
        "Contemporary",
        "Education",
        "Fantasy",
        "Food",
        "Graphic Novels",
        "Historical Fiction",
        "History",
        "Horror",
        "Humour",
        "LGBTQ+",
        "Mystery",
        "Music",
        "Myths & Legends",
        "Nature & Environment",
        "Personal Growth",
        "Poetry",
        "Politics",
        "Psychology",
        "Religion & Spirituality",
        "Romance",
        "Science",
        "Science-Fiction",
        "Short Stories",
        "Sports",
        "Technology",
        "Thriller",
        "Travel",
        "True Crime",
        "Wellness",
        "Young Adult"
    ]
    let meetingTypeChoices: [String] = ["Online", "In-Person"]
    
    init() {
        Task {
            try await fetchBookClubs()
            try await fetchJoinedClubs()
            try await getMessageUserList()
        }
    }
    
    // when a user creates a new book club - save to database and cloud storage
    func saveNewClub(name: String, moderatorName: String, coverImage: UIImage, description: String, genre: String, meetingType: String, isPublic: Bool) async throws {
        let bookClubId = UUID()
        let db = Firestore.firestore()
        // cover image storage
        let storageRef = Storage.storage().reference()
        let imageFilePath = "clubCoverImages/\(UUID().uuidString).jpg"  // ref to save to database
        let fileRef = storageRef.child(
            imageFilePath
        )  // to save image to storage
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("couldn't get the user id")
            return
        }
        
        // new instance of BookClub
        let bookClub = BookClub(
            id: bookClubId,
            name: name,
            moderatorId: userId,
            moderatorName: moderatorName,
            coverImageURL: imageFilePath,
            description: description,
            genre: genre,
            meetingType: meetingType,
            isPublic: isPublic,
            creationDate: Date.now,
            currentBookId: nil,
            booksRead: []
        )
        
        do {
            // create new book club doc
            try db
                .collection("BookClub")
                .document(bookClub.id.uuidString)
                .setData(from: bookClub)
            // add image to storage
            if let imageData = coverImage.jpegData(compressionQuality: 0.8) {
                _ = fileRef
                    .putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print(
                                "error saving image: \(error.localizedDescription)"
                            )
                        }
                    }
            }
        } catch {
            print(
                "failed to save new club details: \(error.localizedDescription)"
            )
        }
        
        self.bookClub = bookClub
        self.allClubs.append(bookClub)
        self.createdClubs.append(bookClub)
        self.coverImages[bookClubId] = coverImage
    }
    
    // fetch all clubs and their cover images
    func fetchBookClubs() async throws {
        self.allClubs.removeAll()
        self.createdClubs.removeAll()
        self.coverImages.removeAll()
        
        // logged in user's userId - for fetching user's created book clubs
        guard let userId = Auth.auth().currentUser?.uid else {
            print("couldn't get the id to fetch details")
            return
        }
        
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        
        do {
            // fetch docs where moderatorId is the same as current userId
            let querySnapshot = try await db.collection("BookClub").getDocuments()
            
            for document in querySnapshot.documents {
                // create BookClub object from document data
                let bookClub = try document.data(as: BookClub.self)
                self.allClubs.append(bookClub)
                
                // if user logged in is a club moderator
                if bookClub.moderatorId == userId {
                    self.createdClubs.append(bookClub)
                }
                
                // get cover image for each club
                let imageRef = storageRef.child(
                    bookClub.coverImageURL
                )  // image file to look for
                imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(
                            "error occured fetching image: \(error.localizedDescription)"
                        )
                    } else if let data = data {
                        let image = UIImage(data: data)
                        // add bookClubId and cover image to dictionary
                        self.coverImages[bookClub.id] = image
                    }
                }
            }
        } catch {
            print("error getting book club documents: \(error)")
        }
    }
    
    func fetchJoinedClubs() async throws {
        self.joinedClubs.removeAll()
        let db = Firestore.firestore()
        
        // get logged in user's id
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let snapshot = try? await Firestore.firestore().collection("User").document(userId).getDocument()
        // new instance of User
        let user = try snapshot?.data(as: User.self)
        
        do {
            // check if User has joinedClubs array
            if let joinedClubs = user?.joinedClubs {
                for id in joinedClubs {
                    // look for BookClub ids in db matching ones in the array
                    let querySnapshot = try await db.collection("BookClub").whereField("id", isEqualTo: id).getDocuments()
                    
                    // loop matching docs
                    for document in querySnapshot.documents {
                        // new BookClub object
                        let bookClub = try document.data(as: BookClub.self)
                        self.joinedClubs.append(bookClub)
                    }
                }
            }
        } catch {
            print("error fetching joined clubs: \(error.localizedDescription)")
        }
    }
    
    func joinClub(bookClub: BookClub, currentUser: User?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("couldn't get user's id to join club")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("User").document(userId)
        
        do {
            // update 'joinedClubs' array in 'User'
            try await userRef.setData([
                "joinedClubs": FieldValue.arrayUnion([bookClub.id.uuidString])
            ], merge: true)
            self.joinedClubs.append(bookClub)
            
            if let currentUser {
                let bookClubMember = BookClubMembers(bookClubId: bookClub.id, bookClubName: bookClub.name, userId: userId, userName: currentUser.name, profilePictureURL: currentUser.profilePictureURL)
                // add member info to db
                try db.collection("BookClubMembers").document(bookClubMember.id.uuidString).setData(from: bookClubMember)
            }
            
            print("success joining club")
        } catch {
            print("error joining club: \(error.localizedDescription)")
        }
    }
    
    // ref: https://stackoverflow.com/questions/42822838/how-to-get-the-number-of-real-words-in-a-text-in-swift
    // to get word count of book club description
    func getWordCount(str: String) -> Int {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(
            .punctuationCharacters
        )
        let components = str.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        return words.count
    }
    
    // for clubs on explore page
    func checkIsMember(bookClub: BookClub) -> Bool {
        return joinedClubs.contains(where: { $0.id.uuidString == bookClub.id.uuidString })
    }
    
    // filter and sort book clubs on Explore page lists
    func filterAndSortArray(clubsArr: [BookClub], selectedSortBy: String?, selectedGenre: String?) -> [BookClub] {
        var filteredArray = clubsArr
        
        if let selectedGenre {
            // only show genre selected
            filteredArray = filteredArray.filter { $0.genre == selectedGenre }
        }
        
        switch selectedSortBy {
        case "Date Created":
            // sort in alphabetical order
            filteredArray = filteredArray.sorted { $0.creationDate > $1.creationDate }
        case "Name":
            // sort by date created - newest first
            filteredArray = filteredArray.sorted { $0.name.lowercased() < $1.name.lowercased() }
        default:
            break
        }
        
        return filteredArray
    }
    
    // rename to getUserMessagingList() ??
    func getMessageUserList() async throws {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        var members: [BookClubMembers] = []
        
        do {
            // loop joinedClubs array
            for club in joinedClubs {
                // search 'BookClubMembers' collection
                let querySnapshot = try await db.collection("BookClubMembers").whereField("bookClubId", isEqualTo: club.id.uuidString).getDocuments()
                
                for document in querySnapshot.documents {
                    // new BookClubMember object
                    let clubMember = try document.data(as: BookClubMembers.self)
                    if clubMember.userId != Auth.auth().currentUser!.uid {
                        members.append(clubMember)
                    }
                    
                    // where to get profile picture from storage
                    let imageRef = storageRef.child(
                        clubMember.profilePictureURL
                    )
                    
                    // get the image
                    imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(
                                "error occured fetching image: \(error.localizedDescription)"
                            )
                        } else if let data = data {
                            let image = UIImage(data: data)
                            // save user id and image to dictionary
                            self.memberPics[clubMember.userId] = image
                        }
                    }
                }
            }
            print("successfully fetched message user list")
        } catch {
            print("error fetching message user list: \(error.localizedDescription)")
        }
        
        self.messageUsers = members
    }
    
    // change to get the moderators name and picture from 'User'
    func getModeratorAndMemberPics(bookClubId: UUID, moderatorId: String, authViewModel: AuthViewModel) async throws {
        self.moderatorInfo.removeAll()
        self.clubMemberPics.removeAll()
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()

        do {
            // get member pics
            let querySnapshot = try await db.collection("BookClubMembers").whereField("bookClubId", isEqualTo: bookClubId.uuidString).getDocuments()

            for document in querySnapshot.documents {
                let clubMember = try document.data(as: BookClubMembers.self)
                let imageRef = storageRef.child(clubMember.profilePictureURL)
                
                // get the image
                imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(
                            "error occured fetching image: \(error.localizedDescription)"
                        )
                    } else if let data = data {
                        let image = UIImage(data: data)
                        // save user id and image to dictionary
                        self.clubMemberPics.append(image ?? UIImage())
                    }
                }
            }
            
            // get moderator pic
            if moderatorId != Auth.auth().currentUser?.uid {
                let document = try await db.collection("User").document(moderatorId).getDocument()
                let moderator = try document.data(as: User.self)
                let imageRef = storageRef.child(moderator.profilePictureURL)
                
                // get the image
                imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(
                            "error occured fetching image: \(error.localizedDescription)"
                        )
                    } else if let data = data {
                        let image = UIImage(data: data)
                        // save user id and image to dictionary
                        self.moderatorInfo[moderator.name] = image ?? UIImage()
                    }
                }
            } else {
                self.moderatorInfo[authViewModel.currentUser?.name ?? ""] = authViewModel.profilePic ?? UIImage()
            }
        } catch {
            print("Error fetching book club member pictures: \(error.localizedDescription)")
        }
    }
    
    func leaveClub(bookClubId: UUID, eventViewModel: EventViewModel) async throws {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // remove club from joined clubs array
        self.joinedClubs.removeAll { $0.id == bookClubId }
        
        // remove from joinedClubs field in User collection
       try await db.collection("User").document(userId)
            .updateData(["joinedClubs": FieldValue.arrayRemove([bookClubId.uuidString])])
        
        // delete document from BookClubMembers with matching bookClubId and userId
        do {
            let querySnapshot = try await db.collection("BookClubMembers")
                .whereField("bookClubId", isEqualTo: bookClubId.uuidString)
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
                        
            if let document = querySnapshot.documents.first {
                try await db.collection("BookClubMembers").document(document.documentID).delete()
            }
        } catch {
            print("Error deleting BookClubMembers document: \(error.localizedDescription)")
        }

        // remove from eventAttendees
        do {
            let querySnapshot = try await db.collection("EventAttendees")
                .whereField("bookClubId", isEqualTo: bookClubId.uuidString)
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            if let document = querySnapshot.documents.first {
                try await db.collection("EventAttendees").document(document.documentID).delete()
            }
        } catch {
            print("Error deleting EventAttendees document: \(error.localizedDescription)")
        }
        
        // remove events from joinedEvents in eventViewModel
        eventViewModel.joinedEvents.removeAll(where: { $0.bookClubId == bookClubId })
    }
    
    // for the book club filter on events page
    func joinedAndCreatedClubNames() -> [String] {
        var clubNameString: [String] = []
        
        for i in joinedClubs {
            clubNameString.append(i.name)
        }
        for i in createdClubs {
            clubNameString.append(i.name)
        }
        
        return clubNameString.sorted(by: { $0.lowercased() < $1.lowercased() })
    }
    
    
    func updateBookClubDetails(bookClub: BookClub, clubName: String, description: String, isPublic: Bool, coverImage: UIImage) async throws {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        var updatedData: [String: Any] = [:]
        
        if clubName != bookClub.name {
            updatedData["name"] = clubName
        }
        if description != bookClub.description {
            updatedData["description"] = description
        }
        if isPublic != bookClub.isPublic {
            updatedData["isPublic"] = isPublic
        }
        if coverImage != coverImages[bookClub.id] {
            let imageFilePath = "clubCoverImages/\(UUID().uuidString).jpg"
            let fileRef = storageRef.child(imageFilePath)
            updatedData["coverImageURL"] = imageFilePath  // to save to db
            
            // add new image to storage
            if let imageData = coverImage.jpegData(compressionQuality: 0.8) {
                _ = fileRef
                    .putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print(
                                "error saving updated image: \(error.localizedDescription)"
                            )
                        }
                    }
            }
            
            // delete old image
            let oldImageRef = storageRef.child(bookClub.coverImageURL)
            do {
                try await oldImageRef.delete()
            } catch {
                print("error deleting old club cover image: \(error.localizedDescription)")
            }

            self.coverImages[bookClub.id] = coverImage
        }
        
        do {
            try await db.collection("BookClub").document(bookClub.id.uuidString).setData(updatedData, merge: true)
        } catch {
            print("error updating book club details: \(error.localizedDescription)")
        }
        
        // update book club in ui
        Task {
            try await fetchBookClubs()
            try await fetchJoinedClubs()
        }
    }
    
    func deleteClub(bookClubId: UUID) async throws {
        do {
            let doc = try await db.collection("BookClub").document(bookClubId.uuidString).getDocument()
            let bookClub = try doc.data(as: BookClub.self)
            try await storageRef.child(bookClub.coverImageURL).delete()
            try await doc.reference.delete()
            
            self.allClubs.removeAll { $0.id == bookClubId }
            self.createdClubs.removeAll { $0.id == bookClubId }
            print("deleted book club and cover image")
        } catch {
            print("Error removing document: \(error)")
        }
    }
}
