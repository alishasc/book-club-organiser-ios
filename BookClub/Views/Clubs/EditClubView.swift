//
//  EditClubView.swift
//  BookClub
//
//  Created by Alisha Carrington on 24/04/2025.
//

import SwiftUI
import PhotosUI

struct EditClubView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var photosPickerViewModel: PhotosPickerViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?  // navigate between textfields
    var bookClub: BookClub
    // form fields
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var wordCount: Int = 0
    @State private var isPublic: Bool = false
    @State private var showAlert: Bool = false
    
    // textfields
    enum Field: Hashable {
        case clubName, description
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                imageSelection
                textFields
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
            
            HStack() {
                Spacer()
                Button {
                    showAlert = true
                } label: {
                    Text("Delete Club")
                        .foregroundStyle(.red)
                        .fontWeight(.medium)
                }
                .alert("Are you sure you want to delete \(bookClub.name)?", isPresented: $showAlert) {
                    Button("Delete \(bookClub.name)", role: .destructive) {
                        Task {
                            try await bookClubViewModel.deleteClub(bookClubId: bookClub.id)
                            // go back to clubs page
                            dismiss()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
                Spacer()
            }
        }
        .padding()
        .ignoresSafeArea(.keyboard)
        .navigationTitle("Edit Club")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // make copies of stored data
            name = bookClub.name
            description = bookClub.description
            wordCount = bookClubViewModel.getWordCount(str: bookClub.description)
            isPublic = bookClub.isPublic
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    withAnimation {
                        // put function to update data in db
                        Task {
                            try await bookClubViewModel.updateBookClubDetails(bookClub: bookClub, clubName: name, description: description, isPublic: isPublic, coverImage: (photosPickerViewModel.selectedImage ?? bookClubViewModel.coverImages[bookClub.id]) ?? UIImage())
                        }
                        dismiss()
                    }
                }
                // button disabled if nothing's changed
                .disabled(
                    photosPickerViewModel.selectedImage == nil &&
                    name == bookClub.name &&
                    description == bookClub.description &&
                    isPublic == bookClub.isPublic
                )
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
    }
    
    private var imageSelection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // cover image
            HStack {
                Text("Cover image")
                    .fontWeight(.medium)
                // edit or remove picture after selected
                if photosPickerViewModel.selectedImage == nil {
                    Spacer()
                    PhotosPicker(selection: $photosPickerViewModel.pickerItem, matching: .images) {
                        Text("Edit picture")
                            .foregroundStyle(.customBlue)
                            .fontWeight(.medium)
                    }
                } else {
                    Spacer()
                    PhotosPicker(selection: $photosPickerViewModel.pickerItem, matching: .images) {
                        Text("Edit picture")
                            .foregroundStyle(.customBlue)
                            .fontWeight(.medium)
                    }
                    
                    Button("Revert changes") {
                        photosPickerViewModel.pickerItem = nil
                        photosPickerViewModel.selectedImage = nil
                    }
                    .foregroundStyle(.red)
                    .fontWeight(.medium)
                }
            }
            .zIndex(1)  // so buttons on top of image
            
            // show photo picker or the selected image
            if photosPickerViewModel.selectedImage == nil {
                GeometryReader { geometry in
                    Image(uiImage: bookClubViewModel.coverImages[bookClub.id] ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 180)  // of image
                        .cornerRadius(10)
                        .clipped()
                }
                .frame(height: 180)  // constrict GeometryReader height
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
        }
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
}
    //#Preview {
    //    EditClubView()
    //}
