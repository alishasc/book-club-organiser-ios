//
//  CreateEventView.swift
//  BookClub
//
//  Created by Alisha Carrington on 24/02/2025.
//

import SwiftUI

// form to create a new event

struct CreateEventView: View {
    @StateObject var eventViewModel: EventViewModel
    let durationChoices: [String] = ["30 minutes", "1 hour", "1 hour 30 minutes", "2 hours"]
    
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
    
    var body: some View {
        VStack {
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
                    // ask for meeting link if online book club
                    ViewTemplates.textField(placeholder: "Virtual meeting link", input: $meetingLink, isSecureField: false)
                        .focused($focusedField, equals: .location)
                        .onSubmit {
                            focusedField = nil
                        }
                } else {
                    // use mapkit for this to search location?
                    ViewTemplates.textField(placeholder: "Event address", input: $location, isSecureField: false)
                        .focused($focusedField, equals: .location)
                        .onSubmit {
                            focusedField = nil
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
                    // convert duration selected into Int - switch
                    var durationInt: Int
                    switch (duration) {
                    case "30 minutes":
                        durationInt = 30
                    case "1 hour":
                        durationInt = 60
                    case "1 hour 30 minutes":
                        durationInt = 90
                    case "2 hours":
                        durationInt = 120
                    default:
                        durationInt = 0
                    }
                    
                    // call function to save new event
                    Task {
                        try await eventViewModel.saveNewEvent(bookClubId: bookClubId, eventTitle: title, dateAndTime: dateAndTime, duration: durationInt, maxCapacity: maxCapacity + 1, meetingLink: meetingLink, location: location)
                    }
                }
            }
        }
    }
}

#Preview {
    CreateEventView(eventViewModel: EventViewModel(), meetingType: "Online", bookClubId: UUID())
}
