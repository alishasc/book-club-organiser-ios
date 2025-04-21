//
//  CreateClubView.swift
//  BookClub
//
//  Created by Alisha Carrington on 06/02/2025.
//

import SwiftUI
import PhotosUI

struct CreateClubView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var photosPickerViewModel: PhotosPickerViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?  // navigate between textfields
    // form fields
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var wordCount: Int = 0
    @State private var genre: String = "Art & Design"
    @State private var meetingType: String = "Online"
    @State private var isPublic: Bool = false
    @State private var showClubDetails: Bool = false  // show club details after confirm
    
    // textfields
    enum Field: Hashable {
        case clubName, description
    }
    
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
                            // edit or remove picture after selected
                            if photosPickerViewModel.selectedImage != nil {
                                Spacer()
                                PhotosPicker(selection: $photosPickerViewModel.pickerItem, matching: .images) {
                                    Text("Edit")
                                        .foregroundStyle(.customBlue)
                                        .fontWeight(.medium)
                                }
                                
                                Button("Remove") {
                                    photosPickerViewModel.pickerItem = nil
                                    photosPickerViewModel.selectedImage = nil
                                }
                                .foregroundStyle(.red)
                                .fontWeight(.medium)
                            }
                        }
                        .zIndex(1)  // put hstack at top of zstack
                        
                        // show photo picker or the selected image
                        if photosPickerViewModel.selectedImage == nil {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 180)
                                    .foregroundColor(.quaternaryHex)
                                
                                PhotosPicker(selection: $photosPickerViewModel.pickerItem, matching: .images) {
                                    Label("Add cover image", systemImage: "plus")
                                        .labelStyle(.iconOnly)
                                        .font(.system(size: 60)).bold()
                                        .foregroundStyle(.white)
                                }
                            }
                        } else {
                            if let image = photosPickerViewModel.selectedImage {
                                GeometryReader { geometry in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width, height: 180)  // of image
                                        .cornerRadius(10)
                                }
                                .frame(height: 180)  // constrict GeometryReader height
                            }
                        }
                    } // vstack
                } // zstack
                
                ViewTemplates.textField(placeholder: "Club name", input: $name, isSecureField: false)
                    .focused($focusedField, equals: .clubName)
                    .onSubmit {
                        focusedField = .description
                    }
                
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
                
                // word count
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
                        ForEach(bookClubViewModel.genreChoices, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // is the club online or in-person?
                HStack {
                    Text("Where will your club meet?")
                        .fontWeight(.medium)
                    Spacer()
                    Picker("Where will your club meet?", selection: $meetingType) {
                        ForEach(bookClubViewModel.meetingTypeChoices, id: \.self) {
                            Text($0)
                        }
                    }
                    .offset(x: 10)
                }
            }
            .padding(.bottom, 15)
            
            // make the club public to everyone?
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
        .ignoresSafeArea(.keyboard)
        .navigationTitle("Create a New Club")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm") {
                    let coverImage: UIImage?
                    if let selectedImage = photosPickerViewModel.selectedImage {
                        coverImage = selectedImage
                    } else {
                        coverImage = UIImage(named: "banner") ?? UIImage()
                    }
                    
                    Task {
                        // add new club to db
                        try await bookClubViewModel.saveNewClub(name: name, moderatorName: authViewModel.currentUser?.name ?? "", coverImage: coverImage ?? UIImage(), description: description, genre: genre, meetingType: meetingType, isPublic: isPublic)
                    }

                    // show details of new club after press confirm
                    showClubDetails = true
                    photosPickerViewModel.selectedImage = nil  // reset image selection
                }
                .disabled(name.isEmpty || description.isEmpty)  // complete form to submit
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    photosPickerViewModel.pickerItem = nil
                    photosPickerViewModel.selectedImage = nil
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .fontWeight(.medium)
                        Text("Back")
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showClubDetails) {
            if let bookClub = bookClubViewModel.bookClub {
                BookClubDetailsView(bookClub: bookClub, isModerator: true, isMember: false)
            }
        }
    }
}

#Preview {
    CreateClubView()
        .environmentObject(BookClubViewModel())
}
