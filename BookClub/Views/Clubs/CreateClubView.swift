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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    // so cover image title and edit picture are on top of selected image
                    imageSelection
                    textFields
                    pickers
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
        }
        .padding()
        .padding(.bottom)
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea(edges: .bottom)
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
            ToolbarItemGroup(placement: .keyboard) {
                if focusedField == .description {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showClubDetails) {
            if let bookClub = bookClubViewModel.bookClub {
                ClubHostView(bookClub: bookClub, isModerator: true, isMember: false)
            }
        }
    }
    
    private var imageSelection: some View {
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
                            .clipped()
                    }
                    .frame(height: 180)  // constrict GeometryReader height
                }
            }
        } // vstack
    }
    private var textFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewTemplates.textField(placeholder: "Club name", input: $name, isSecureField: false)
                .focused($focusedField, equals: .clubName)
                .onSubmit {
                    focusedField = .description
                }
                .submitLabel(.next)
            
            Text("Description")
                .fontWeight(.medium)
            TextEditor(text: $description)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
                .focused($focusedField, equals: .description)
                .onChange(of: description) {
                    wordCount = bookClubViewModel.getWordCount(str: description)
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
        }
    }
    private var pickers: some View {
        VStack(spacing: 10) {
            // choose club genre
            VStack(alignment: .leading, spacing: 5) {
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
                Text("You won’t be able to change the club’s genre later.")
                    .font(.footnote)
                    .foregroundColor(.accent)
            }
                
            VStack(alignment: .leading, spacing: 5) {
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
                Text("You won’t be able to change the meeting type after creating the club.")
                    .font(.footnote)
                    .foregroundColor(.accent)
            }
        }
    }
}

#Preview {
    CreateClubView()
        .environmentObject(BookClubViewModel())
}
