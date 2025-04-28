//
//  EditEventView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/04/2025.
//

import SwiftUI
import Firebase
import MapKit

struct EditEventView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) var dismiss
    var bookClub: BookClub
    var event: Event
    // copied data below
    @State private var title: String = ""
    @State private var dateAndTime = Date()
    @State private var duration: String = ""
    @State private var locationName: String = "Loading..."
    @State private var meetingLink: String = ""
    @State private var searchInput: String = ""  // for textfield
    @State private var isLocationSelected: Bool = false  // when tap search result
    @State private var showAlert: Bool = false  // to delete the event
    
    let durationChoices: [String] = ["", "30 minutes", "1 hour", "1 hour 30 minutes", "2 hours"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewTemplates.textField(placeholder: "Event title", input: $title, isSecureField: false)
            
            DatePicker(
                "Date & time",
                selection: $dateAndTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            .fontWeight(.medium)
            
            HStack {
                Text("Event duration")
                    .fontWeight(.medium)
                Spacer()
                Picker("Event duration", selection: $duration) {
                    ForEach(durationChoices, id: \.self) {
                        Text("\($0)")
                    }
                }
                .offset(x: 10)  // move picker right
            }
            
            if bookClub.meetingType == "Online" {
                ViewTemplates.textField(placeholder: "Virtual meeting link", input: $meetingLink, isSecureField: false)
            } else {
                // tfield to search event address
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Address")
                        .fontWeight(.medium)
                    
                    Text("Current address: \(locationName)")
                        .font(.subheadline)
                        .foregroundStyle(Color(.darkGray))
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .padding(.leading, 10)  // inside textfield
                        TextField("Search new address", text: $searchInput)
                            .padding([.top, .bottom, .trailing], 10)  // inside textfield
                            .onSubmit {
                                Task {
                                    // check input is valid and get search results
                                    try await eventViewModel.locationFieldValidation(query: searchInput)
                                }
                            }
                    }
                    .background(.quinary)
                    .cornerRadius(10)
                    
                    if !eventViewModel.searchResults.isEmpty {
                        List {
                            ForEach(eventViewModel.searchResults, id: \.self) { location in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    // highlight tapped location
                                        .foregroundStyle(location == eventViewModel.selectedLocation ? .accent : .clear)
                                    VStack(alignment: .leading) {
                                        Text("\(location.placemark.name ?? "")\n\(location.placemark.title ?? "")")
                                        // change text colour if selected
                                            .foregroundStyle(location == eventViewModel.selectedLocation ? .white : .primary)
                                            .lineLimit(3)
                                    }
                                    .padding()
                                }
                                .onTapGesture {
                                    isLocationSelected = true
                                    eventViewModel.selectedLocation = location
                                }
                                .onChange(of: searchInput) {
                                    // unselect location
                                    eventViewModel.selectedLocation = nil
                                }
                            }
                        }
                        .listStyle(.plain)
                        .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20))  // extend list rows to edges of screen
                        .scrollIndicators(.hidden)
                    } else {
                        // show error message is invalid input
                        Text(eventViewModel.locationErrorPrompt)
                            .padding(.top, 20)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            HStack() {
                Spacer()
                Button {
                    showAlert = true
                } label: {
                    Text("Delete Event")
                        .foregroundStyle(.red)
                        .fontWeight(.medium)
                }
                .alert("Are you sure you want to delete this event?", isPresented: $showAlert) {
                    Button("Delete event", role: .destructive) {
                        Task {
                            try await eventViewModel.deleteEvent(eventId: event.id)
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
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // make copies of stored data as @State vars
            title = event.eventTitle
            dateAndTime = event.dateAndTime
            
            switch(event.duration) {
            case 30:
                duration = durationChoices[1]
            case 60:
                duration = durationChoices[2]
            case 90:
                duration = durationChoices[3]
            case 120:
                duration = durationChoices[4]
            default:
                break
            }
            
            if bookClub.meetingType == "Online" {
                meetingLink = event.meetingLink ?? ""
            } else {
                if let coords = event.location {
                    eventViewModel.getLocationPlacemark(location: coords, completionHandler: { placemark in
                        // get name from placemark
                        if let name = placemark?.name {
                            self.locationName = name
                        }
                    })
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    withAnimation {
                        Task {
                            // MARK: function to update db
                            try await eventViewModel.updateEventDetails(
                                event: event,
                                title: title,
                                dateAndTime: dateAndTime,
                                duration: eventViewModel.formatDurationToInt(minutes: duration),
                                meetingLink: meetingLink,
                                location:
                                    eventViewModel.selectedLocation == nil ? event.location : GeoPoint(latitude: eventViewModel.selectedLocation?.placemark.coordinate.latitude ?? 0, longitude: eventViewModel.selectedLocation?.placemark.coordinate.longitude ?? 0)
                            )
                        }
                        dismiss()
                    }
                }
                .disabled(
                    title == event.eventTitle &&
                    dateAndTime == event.dateAndTime &&
                    eventViewModel.formatDurationToInt(minutes: duration) == event.duration &&
                    (bookClub.meetingType == "Online" ?
                     meetingLink == event.meetingLink :
                        (eventViewModel.selectedLocation == nil || locationName == eventViewModel.selectedLocation?.name ?? ""))
                )
            }
        }
    }
}

//#Preview {
//    EditEventView(bookClub: bookClubViewModel.allClubs[0], event: eventViewModel.allEvents[0])
//}
