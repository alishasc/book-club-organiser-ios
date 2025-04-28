//
//  EditProfileView.swift
//  BookClub
//
//  Created by Alisha Carrington on 19/04/2025.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var photosPickerViewModel: PhotosPickerViewModel
    @Environment(\.dismiss) var dismiss
    var profile: User
    var profilePicture: UIImage
    // copy existing data
    @State private var profilePictureCopy: UIImage = UIImage()
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var favouriteGenres: [String] = []
    @State private var location: String = ""
    // trigger sheets
    @State private var showGenreList: Bool = false
    @State private var showLocationSearch: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            editPicture
                .padding(.bottom, 15)
            textfields
            genresAndLocation
            Spacer()
            deleteAccountButton
        }
        .onAppear {
            // make copies of stored data as @State vars
            profilePictureCopy = profilePicture
            name = profile.name
            email = profile.email
            favouriteGenres = profile.favouriteGenres
            location = profile.location
        }
        .sheet(isPresented: $showGenreList, content: {
            EditGenresView(genreChoices: bookClubViewModel.genreChoices, favouriteGenres: $favouriteGenres)
        })
        .sheet(isPresented: $showLocationSearch, content: {
            EditLocationView(location: $location)
        })
        .padding()
        .navigationTitle("Edit Profile")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    withAnimation {
                        Task {
                            try await authViewModel.updateDetails(name: name, email: email, favouriteGenres: favouriteGenres, location: location, profilePicture: photosPickerViewModel.selectedImage ?? profilePicture)
                        }
                        photosPickerViewModel.selectedImage = nil
                        photosPickerViewModel.pickerItem = nil
                        dismiss()
                    }
                }
                // button disabled if nothing's changed
                .disabled(
                    photosPickerViewModel.selectedImage == nil &&
                    name == profile.name &&
                    email == profile.email &&
                    favouriteGenres == profile.favouriteGenres &&
                    location == profile.location
                )
            }
        }
    }
    
    private var editPicture: some View {
        VStack {
            if photosPickerViewModel.selectedImage == nil {
                Image(uiImage: profilePictureCopy)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                
                PhotosPicker(selection: $photosPickerViewModel.pickerItem, matching: .images) {
                    Text("Edit picture")
                        .foregroundStyle(.customBlue)
                        .fontWeight(.medium)
                }
            } else {
                if let image = photosPickerViewModel.selectedImage {
                    VStack(spacing: 5) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        
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
            }
        }
    }
    private var textfields: some View {
        VStack(spacing: 15) {
            ViewTemplates.textField(placeholder: "Name", input: $name, isSecureField: false)
            ViewTemplates.textField(placeholder: "Email", input: $email, isSecureField: false)
        }
    }
    private var genresAndLocation: some View {
        VStack(spacing: 15) {
            // edit favourite genres
            HStack {
                Button {
                    showGenreList.toggle()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Favourite Genres")
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                            Text(favouriteGenres.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                            .font(.system(size: 24))
                    }
                }
                Spacer()
            }
            
            // edit location
            HStack {
                Button {
                    showLocationSearch.toggle()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Location")
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                            if location == "" {
                                Text("No location selected")
                                    .font(.subheadline)
                                    .foregroundStyle(.black)
                            } else {
                                Text(location)
                                    .font(.subheadline)
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                            .font(.system(size: 24))
                    }
                }
                Spacer()
            }
        }
    }
    private var deleteAccountButton: some View {
        // log out button
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 350, height: 45)
                .foregroundStyle(.quinary)

            Button {
                showAlert = true
            } label: {
                Text("Delete Account")
                    .foregroundStyle(.red)
                    .fontWeight(.medium)
                    .padding(.leading)
            }
            .alert("Are you sure you want to delete your account?", isPresented: $showAlert) {
                Button("Delete account", role: .destructive) {
                    Task {
                        try await authViewModel.deleteUserAccount()
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}

func toggleGenre(favouriteGenres: [String], genre: String) -> [String] {
    var updatedGenres = favouriteGenres
    
    if updatedGenres.contains(genre) {
        updatedGenres.removeAll { $0 == genre }
    } else {
        if updatedGenres.count < 5 {
            updatedGenres.append(genre)
        }
    }
    
    return updatedGenres
}

//#Preview {
//    EditProfileView()
//}

