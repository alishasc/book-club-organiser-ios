//
//  PhotosPickerViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 05/03/2025.
//

// ref: https://www.youtube.com/watch?v=IZEYVX4vTOA

import Foundation
import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

@MainActor
class PhotosPickerViewModel: ObservableObject {
    // to show image in app
    @Published var selectedImage: UIImage? = nil
    // actual selected image from phone
    @Published var pickerItem: PhotosPickerItem? = nil {
        didSet {
            setImage(from: pickerItem)
        }
    }
    @Published var coverImage: UIImage? = nil  // fetched for one club
    
    // called whenever pickerItem is updated (didSet)
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    return
                }
            }
        }
    }
    
    // add image to Firebase Cloud Storage and its ref to Firestore
    func uploadPhoto(bookClubId: UUID) async throws {
        // check an image has been selected
        guard selectedImage != nil else {
            print("no selected image")
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageFilePath = "clubCoverImages/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(imageFilePath)
                
        if let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
            _ = fileRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    print("error uploading image: \(error?.localizedDescription ?? "no error description")")
                    return
                }
                print("successfully uploaded image")
            }
        }

        // save image ref to firestore
        let db = Firestore.firestore()
        let bookClubRef = db.collection("BookClub").document(bookClubId.uuidString)
        
        do {
            try await bookClubRef.setData(["coverImage": imageFilePath], merge: true)
            print("image ref added to firebase")
        } catch {
            print("error saving image ref: \(error.localizedDescription)")
        }
    }
    
    // don't use?
    func retrieveCoverImage(bookClubId: UUID) async throws {
        let db = Firestore.firestore()
        
        let docRef = db.collection("BookClub").document(bookClubId.uuidString)
        
        do {
            let bookClub = try await docRef.getDocument(as: BookClub.self)
            print("success")
            
            if let coverImage = bookClub.coverImage {
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child(coverImage)
                
                imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error occured: \(error)")
                    }
                    //                    else {
                    //                        self.coverImage = UIImage(data: data!)
                    //                    }
                }
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    // get image that matches the string given - BookClubDetailsView
    func retrieveCoverImage2(coverImage: String) async throws {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(coverImage)
        
        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("error occured retrieving image: \(error.localizedDescription)")
            } else {
                self.coverImage = UIImage(data: data!)
            }
        }
    }
}

