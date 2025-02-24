//
//  CreateEventView.swift
//  BookClub
//
//  Created by Alisha Carrington on 24/02/2025.
//

import SwiftUI

// form to create a new event

struct CreateEventView: View {
    let durationChoices: [String] = ["30 minutes", "1 hour", "1 hour 30 minutes", "2 hours"]
    
    // textfields
    enum Field: Hashable {
        case spacesAvailable, location
    }
    
    var isOnline: Bool  // pass from previous screen - get info from book club data
    @FocusState private var focusedField: Field?  // to navigate between textfields
    @State private var title: String = ""
    @State private var dateAndTime = Date()
    @State private var duration: String = "1 hour"
    @State private var maxCapacity: String = ""
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
                    Picker("Meeting duration", selection: $duration) {
                        ForEach(durationChoices, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .offset(x: 10)  // move picker right
                }
                
                // select how many spaces there are
                ViewTemplates.textField(placeholder: "Number of spaces available", input: $maxCapacity, isSecureField: false)
                    .focused($focusedField, equals: .spacesAvailable)
                    .onSubmit {
                        focusedField = .location
                    }
                
                if isOnline {
                    // ask for meeting link if online book club
                    ViewTemplates.textField(placeholder: "Virtual meeting link", input: $location, isSecureField: false)
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
        .navigationTitle(Text("Create a New Event"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CreateEventView(isOnline: false)
}
