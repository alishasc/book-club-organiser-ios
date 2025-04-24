//
//  EventPopupView.swift
//  BookClub
//
//  Created by Alisha Carrington on 20/03/2025.
//

import SwiftUI
import MapKit

struct EventPopupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    var bookClub: BookClub
    var event: Event
    var coverImage: UIImage
    var isModerator: Bool
    @Binding var isAttendingEvent: Bool
    private var position: MapCameraPosition
    // for location Text
    @State private var locationName: String = "Loading..."
    @State private var city: String = "Loading..."
    @State private var postcode: String = "Loading..."
    
    @Binding private var spacesLeft: Int
        
    init(bookClub: BookClub, event: Event, coverImage: UIImage, isModerator: Bool, isAttendingEvent: Binding<Bool>, spacesLeft: Binding<Int>) {
        self.bookClub = bookClub
        self.event = event
        self.coverImage = coverImage
        self.isModerator = isModerator
        self._isAttendingEvent = isAttendingEvent
        self.position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.location?.latitude ?? 0, longitude: event.location?.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)))
        self._spacesLeft = spacesLeft
    }
    
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
                eventInfo
                membersAttending
                Divider()
                // online meeting link/address and map
                meetingLocation
            }
            .padding(.horizontal)
                        
            Spacer()
        }  // vstack
        .onAppear {
            Task {
                // function to get moderator and attendee images
                try await eventViewModel.getModeratorAndAttendeePics(bookClubId: bookClub.id, eventId: event.id, moderatorId: bookClub.moderatorId, authViewModel: authViewModel)
            }
        }
    }

    private var eventInfo: some View {
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
                Text("\(spacesLeft) spaces left")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            // checkmark icon
            if !isModerator {
                Image(systemName: isAttendingEvent ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(.accent)
                    .onTapGesture {
                        isAttendingEvent.toggle()
                        // call function to un/reserve space for event
                        Task {
                            try await eventViewModel.attendEvent(isAttending: isAttendingEvent, event: event, bookClub: bookClub)
                        }
                    }
            }
        }
    }
    
    private var membersAttending: some View {
        HStack(alignment: .top, spacing: 60) {
            // host info
            VStack(alignment: .leading, spacing: 4) {
                Text("Host:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
                // host profile pic
                Image(uiImage: eventViewModel.moderatorPic)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }

            // attending members info
            VStack(alignment: .leading, spacing: 4) {
                Text("Attending members:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if eventViewModel.eventAttendeePics.count > 0 {
                    // member profile pics
                    HStack(spacing: -5) {
                        ForEach(eventViewModel.eventAttendeePics, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        }
                    }
                } else {
                    Text("No one yet!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    private var meetingLocation: some View {
        VStack(alignment: .leading) {
            if bookClub.meetingType == "Online" {
                Text("Online")
                    .fontWeight(.semibold)
                // meeting link here
                if let link = event.meetingLink {
                    // add default link here!
                    Link(destination: URL(string: link)!) {
                        Text(link)
                            .foregroundStyle(.customBlue)
                            .underline()
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                    }
                }
            } else {
                Text(locationName)
                    .fontWeight(.semibold)
                Text("\(city), \(postcode)")
                // location on map
                if let geoCoords = event.location {
                    Map(initialPosition: position, interactionModes: [.pan, .zoom]) {
                        Marker("", coordinate: CLLocationCoordinate2D(latitude: geoCoords.latitude, longitude: geoCoords.longitude))
                            .tint(.accent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .cornerRadius(10)
                    .onTapGesture {
                        // open Apple Maps application for location
                        if let url = URL(string: "maps://?q=\(geoCoords.latitude),\(geoCoords.longitude)") {
                            UIApplication.shared.open(url)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            // get event address info
            if let geoPoint = event.location {
                eventViewModel.getLocationPlacemark(location: geoPoint, completionHandler: { placemark in
                    // get name from placemark
                    if let name = placemark?.name {
                        self.locationName = name
                    }
                    if let city = placemark?.locality {
                        self.city = city
                    }
                    if let postcode = placemark?.postalCode {
                        self.postcode = postcode
                    }
                })
            }
        }
    }
}


//#Preview {
//    EventPopupView(bookClub: BookClub(name: "Fantasy Book Club", moderatorId: "", moderatorName: "", coverImageURL: "", description: "", genre: "", meetingType: "Online", isPublic: true, creationDate: Date(), currentBookId: "", booksRead: [""]))
//        .environmentObject(BookClubViewModel())
//}
