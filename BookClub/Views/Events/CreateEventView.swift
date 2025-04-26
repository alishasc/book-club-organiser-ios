//
//  CreateEventView.swift
//  BookClub
//
//  Created by Alisha Carrington on 24/02/2025.
//

import SwiftUI
import MapKit

// form to create a new event

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventViewModel: EventViewModel
    let durationChoices: [String] = ["30 minutes", "1 hour", "1 hour 30 minutes", "2 hours"]
    @State private var searchInput: String = ""  // in textfield
    @State private var isLocationSelected: Bool = false  // when tap search result
    
    // textfields
    enum Field: Hashable {
        case spacesAvailable, location
    }
    
    // pass from previous screen - get info from book club data
    var meetingType: String
    var bookClubId: UUID
    @FocusState private var focusedField: Field?  // to navigate between textfields
    @State private var title: String = ""
    @State private var dateAndTime = Date()
    @State private var duration: String = "1 hour"
    @State private var maxCapacity: Int = 14  // add one to this later because of Picker
    @State private var meetingLink: String = ""
    @State private var location: String = ""
    @State private var showClubDetails: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewTemplates.textField(placeholder: "Event title", input: $title, isSecureField: false)
            
            DatePicker(
                "Date & time",
                selection: $dateAndTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            .fontWeight(.medium)
            
            // choose duration
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
            
            // choose number of spaces
            HStack {
                Text("Number of spaces available")
                    .fontWeight(.medium)
                Spacer()
                Picker("Number of spaces available", selection: $maxCapacity) {
                    ForEach(1..<51) {
                        Text($0, format: .number)
                    }
                }
                .offset(x: 10)
            }
            
            if meetingType == "Online" {
                // tfield for meeting link
                ViewTemplates.textField(placeholder: "Virtual meeting link", input: $meetingLink, isSecureField: false)
                    .focused($focusedField, equals: .location)
                    .onSubmit {
                        focusedField = nil
                    }
            } else {
                // tfield to search event address
                VStack(alignment: .leading) {
                    Text("Event Address")
                        .fontWeight(.medium)
                    
                    // textfield
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .padding(.leading, 10)  // inside textfield
                        TextField("Search event address", text: $searchInput)
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
        }
        .padding()
        .navigationTitle("Create a New Event")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm") {
                    // call function to save new event
                    Task {
                        try await eventViewModel.saveNewEvent(bookClubId: bookClubId, eventTitle: title, dateAndTime: dateAndTime, duration: eventViewModel.formatDurationToInt(minutes: duration), maxCapacity: maxCapacity + 1, meetingLink: meetingLink, location: eventViewModel.selectedLocation?.placemark.coordinate ?? CLLocationCoordinate2D())
                        
                        eventViewModel.selectedLocation = nil
                        eventViewModel.searchResults = []
                        dismiss()  // go back to previous screen
                    }
                }
                .disabled(
                    (meetingType == "Online" && (title.isEmpty || meetingLink.isEmpty)) ||
                    (meetingType == "In-Person" && (title.isEmpty || eventViewModel.selectedLocation == nil))
                )
            }
        }
    }
}

#Preview {
    CreateEventView(meetingType: "Online", bookClubId: UUID())
}
