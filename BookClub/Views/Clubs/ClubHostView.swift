//
//  ClubHostView.swift
//  BookClub
//
//  Created by Alisha Carrington on 24/04/2025.
//

import SwiftUI

struct ClubHostView: View {
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
    var bookClub: BookClub
    
    var body: some View {
        VStack {
            // displays the static profile or view for Edit mode
            if editMode?.wrappedValue == .inactive {
                BookClubDetailsView(bookClub: <#T##BookClub#>, isModerator: <#T##Bool#>, isMember: <#T##Bool#>)
            } else {
                EditProfileView(profile: profile, profilePicture: profilePic)
            }
        }
    }
}

#Preview {
    ClubHostView()
}
