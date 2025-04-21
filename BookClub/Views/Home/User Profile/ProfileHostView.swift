//
//  ProfileHostView.swift
//  BookClub
//
//  Created by Alisha Carrington on 19/04/2025.
//

import SwiftUI

struct ProfileHostView: View {
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
    var profile: User
    var profilePic: UIImage
    var joinedClubs: Int
    var createdClubs: Int

    var body: some View {
        VStack {
            // displays the static profile or view for Edit mode
            if editMode?.wrappedValue == .inactive {
                ProfileView(profile: profile, profilePic: profilePic, joinedClubs: joinedClubs, createdClubs: createdClubs)
            } else {
                EditProfileView(profile: profile, profilePicture: profilePic)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if editMode?.wrappedValue == .active {
                    Button("Cancel", role: .cancel) {
                        editMode?.animation().wrappedValue = .inactive
                    }
                }
            }
//            ToolbarItem(placement: .confirmationAction) {
//                if editMode?.wrappedValue == .active {
//                    Button("Save") {
//                        withAnimation {
//                            // put function to save to firebase here
//                            
//                            dismiss()
//                        }
//                    }
//                    .disabled(<#T##disabled: Bool##Bool#>)
//                }
//            }
        }
    }
}

//#Preview {
//    ProfileHostView()
//}
