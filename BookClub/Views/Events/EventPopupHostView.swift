//
//  EventPopupHostView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/04/2025.
//

import SwiftUI

struct EventPopupHostView: View {
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
    var bookClub: BookClub
    var event: Event
    var coverImage: UIImage
    var isModerator: Bool
    @Binding var isAttendingEvent: Bool
    @Binding var spacesLeft: Int
    
    var body: some View {
        VStack {
            if editMode?.wrappedValue == .inactive {
                EventPopupView(bookClub: bookClub, event: event, coverImage: coverImage, isModerator: isModerator, isAttendingEvent: $isAttendingEvent, spacesLeft: $spacesLeft)
            } else {
                EditEventView(bookClub: bookClub, event: event)
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
//    EventPopupHostView()
//}

