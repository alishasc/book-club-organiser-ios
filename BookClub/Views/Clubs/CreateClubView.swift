//
//  CreateClubView.swift
//  BookClub
//
//  Created by Alisha Carrington on 06/02/2025.
//

import SwiftUI
import PhotosUI

struct CreateClubView: View {
    let genreChoices: [String] = ["Art & Design", "Biography", "Business", "Children's Fiction", "Classics", "Contemporary", "Education", "Fantasy", "Food", "Graphic Novels", "Historical Fiction", "History", "Horror", "Humour", "LGBTQ+", "Mystery", "Music", "Myths & Legends", "Nature & Environment", "Personal Growth", "Poetry", "Politics", "Psychology", "Religion & Spirituality", "Romance", "Science", "Science-Fiction", "Short Stories", "Sports", "Technology", "Thriller", "Travel", "True Crime", "Wellness", "Young Adult"]
    let meetingTypeChoices: [String] = ["Online", "In-Person"]
    
    // textfields
    enum Field: Hashable {
        case clubName, description
    }
    
    @StateObject var bookClubViewModel: BookClubViewModel
    @FocusState private var focusedField: Field?  // to navigate between textfields
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var wordCount: Int = 0
    @State private var genre: String = "Art & Design"
    @State private var meetingType: String = "Online"
    @State private var isPublic: Bool = false
    let creationDate: Date = Date.now  // current date and time
    @State private var showClubDetails: Bool = false
    
    // for selecting photo
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                // so cover image title and edit picture are on top of selected image
                ZStack {
                    VStack(alignment: .leading, spacing: 10) {
                        // cover image
                        HStack {
                            Text("Cover image")
                                .fontWeight(.medium)
                            // edit picture once selected
                            if selectedImage != nil {
                                Spacer()
                                PhotosPicker(selection: $pickerItem, matching: .images) {
                                    Text("Edit picture")
                                        .foregroundStyle(.customBlue)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .zIndex(1)  // put hstack at top of zstack
                        
                        // pick cover image
                        if selectedImage == nil {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 180)
                                    .foregroundColor(.quaternaryHex)
                                
                                PhotosPicker(selection: $pickerItem, matching: .images) {
                                    Label("Add cover image", systemImage: "plus")
                                        .labelStyle(.iconOnly)
                                        .font(.system(size: 60)).bold()
                                        .foregroundStyle(.white)
                                }
                            }
                        } else {
                            selectedImage?
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .cornerRadius(10)
                                .onTapGesture {
                                    print("tapped edit")
                                }
                        }
                    } // vstack
                } // zstack
                
                ViewTemplates.textField(placeholder: "Club name", input: $name, isSecureField: false)
                    .focused($focusedField, equals: .clubName)
                    .onSubmit {
                        focusedField = .description
                    }
                
                // change submit label do 'done'
                ViewTemplates.textField(placeholder: "Description", input: $description, isSecureField: false)
                    .focused($focusedField, equals: .description)
                    .onSubmit {
                        focusedField = nil
                    }
                    .onChange(of: description) {
                        wordCount = bookClubViewModel.getWordCount(str: description)
                        
                        // can't add more than 40 words
                        if wordCount == 41 {
                            description.removeLast()
                        }
                    }
                
                HStack {
                    Spacer()
                    Text("\(wordCount)/40")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                // choose club genre
                HStack {
                    Text("What genre best describes your club?")
                        .fontWeight(.medium)
                    Spacer()
                    Picker("", selection: $genre) {
                        ForEach(genreChoices, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // club online or in-person?
                HStack {
                    Text("Where will your club meet?")
                        .fontWeight(.medium)
                    Spacer()
                    Picker("Where will your club meet?", selection: $meetingType) {
                        ForEach(meetingTypeChoices, id: \.self) {
                            Text($0)
                        }
                    }
                    .offset(x: 10)
                }
            }
            .padding(.bottom, 15)
            
            // make club public to everyone?
            Toggle(isOn: $isPublic) {
                Text("Make club public")
                    .fontWeight(.medium)
                Text("Making your club public allows anyone to join.")
                    .font(.subheadline)
            }
            .padding()
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
        }
        .padding()
        .navigationTitle("Create a New Club")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm") {
                    // save new club details to firebase
                    Task {
                        try await bookClubViewModel.saveNewClub(name: name, description: description, genre: genre, meetingType: meetingType, isPublic: isPublic, creationDate: creationDate)
                    }
                    
                    // show the club details for the new club after pressing confirm
                    showClubDetails = true
                }
                .disabled(name.isEmpty || description.isEmpty)  // can't press if form not filled
            }
        }
        .onChange(of: pickerItem) {
            Task {
                selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
            }
        }
        .navigationDestination(isPresented: $showClubDetails) {
            if let bookClub = bookClubViewModel.bookClub {
                BookClubDetailsView(eventViewModel: EventViewModel(), bookClub: bookClub, moderatorName: bookClubViewModel.moderatorName, isModerator: true)
            }
        }
    }
}

#Preview {
    CreateClubView(bookClubViewModel: BookClubViewModel())
}
