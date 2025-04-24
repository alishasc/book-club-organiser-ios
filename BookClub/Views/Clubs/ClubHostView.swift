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
    var isModerator: Bool
    var isMember: Bool
    var coverImage: UIImage
    
    var body: some View {
        VStack {
            // displays the static profile or view for Edit mode
            if editMode?.wrappedValue == .inactive {
                BookClubDetailsView(bookClub: bookClub, isModerator: isModerator, isMember: isMember)
            } else {
                EditClubView(bookClub: bookClub, coverImage: coverImage)
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
        }
    }
}

//#Preview {
//    ClubHostView()
//}
