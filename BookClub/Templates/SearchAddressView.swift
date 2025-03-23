//
//  SearchAddressView.swift
//  BookClub
//
//  Created by Alisha Carrington on 21/03/2025.
//

// textfield and functions for searching locations

import SwiftUI

struct SearchAddressView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var searchInput: String = ""  // in textfield
    @State private var isLocationSelected: Bool = false  // when tap search result
    
    var body: some View {
        VStack {
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
                                Text("\(location.placemark.title ?? "")")
                                // change text colour if selected
                                    .foregroundStyle(location == eventViewModel.selectedLocation ? .white : .primary)
                                    .lineLimit(2)
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
}

#Preview {
    SearchAddressView()
}
