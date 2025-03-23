//
//  EventPopupView.swift
//  BookClub
//
//  Created by Alisha Carrington on 20/03/2025.
//

import SwiftUI

struct EventPopupView: View {
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    var bookClub: BookClub
    var event: Event
    var coverImage: UIImage
    var isModerator: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // cover image
            GeometryReader { geometry in
                if let coverImage = bookClubViewModel.coverImages[bookClub.id] {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 180)  // of image
                        .clipped()
                }
            }
            .frame(height: 180)  // constrict GeometryReader height
            
            VStack(alignment: .leading, spacing: 10) {
                // text info and checkmark
                TextInfo(bookClub: bookClub, event: event, isModerator: isModerator)
                
                // host and members attending
                MembersAttending()
                
                Divider()
                
                // zoom link/map
                MeetingLocation(bookClub: bookClub, event: event)
            }
            .padding(.horizontal)
                        
            Spacer()
        }  // vstack
    }
}

struct TextInfo: View {
    var bookClub: BookClub
    var event: Event
    var isModerator: Bool
    
    var body: some View {
        HStack {
            // text
            VStack(alignment: .leading) {
                Text(bookClub.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(event.eventTitle)
                    .fontWeight(.medium)
                Text(ViewTemplates.eventSheetDateFormatter(dateAndTime: event.dateAndTime))
                Text(ViewTemplates.eventSheetTimeFormatter(dateAndTime: event.dateAndTime))
                    .foregroundStyle(.gray)
                Text("\(event.maxCapacity - event.attendeesCount) spaces left")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            // checkmark icon
            if !isModerator {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.accent)
            }
        }
    }
}

struct MembersAttending: View {
    var body: some View {
        HStack(alignment: .top, spacing: 60) {
            // host info
            VStack(alignment: .leading, spacing: 4) {
                Text("Host:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
                // host profile pic
                Circle()  // replace with image
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.customYellow)
            }

            // attending members info
            VStack(alignment: .leading, spacing: 4) {
                Text("Attending members:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                // member profile pics
                HStack(spacing: -5) {
                    // add ForEach loop here for club members? max 4 pics
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customYellow)
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customGreen)
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customPink)
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customBlue)
                }
            }
            
            Spacer()
        }
    }
}

struct MeetingLocation: View {
    var bookClub: BookClub
    var event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            if bookClub.meetingType == "Online" {
                Text("Online")
                    .fontWeight(.semibold)
                Text(event.meetingLink ?? "")
                    .foregroundStyle(.accent)
            } else {
                Text(event.location ?? "")
                    .fontWeight(.semibold)
                // map view here
            }
        }
    }
}

//#Preview {
//    EventPopupView(bookClub: BookClub(name: "Fantasy Book Club", moderatorId: "", moderatorName: "", coverImageURL: "", description: "", genre: "", meetingType: "Online", isPublic: true, creationDate: Date(), currentBookId: "", booksRead: [""]))
//        .environmentObject(BookClubViewModel())
//}
