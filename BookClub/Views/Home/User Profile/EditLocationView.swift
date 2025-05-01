//
//  EditLocationView.swift
//  BookClub
//
//  Created by Alisha Carrington on 20/04/2025.
//

// for user profile

import SwiftUI

struct EditLocationView: View {
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var location: String
    @State private var searchInput: String = ""
    @State private var isLocationSelected: Bool = false  // when tap search result
    
    var body: some View {
        VStack {
            // current location
            HStack {
                Text("Current location:")
                    .fontWeight(.medium)
                Text(location == "" ? "No location selected" : location)
                Spacer()
            }
            
            // search bar/textfield
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 10)  // inside textfield
                TextField("Search city, county or postcode", text: $searchInput)
                    .padding([.top, .bottom, .trailing], 10)  // inside textfield
                    .onSubmit {
                        Task {
                            // check input is valid and get search results
                            try await onboardingViewModel.getSearchResults(query: searchInput)
                        }
                    }
            }
            .background(.quinary)
            .cornerRadius(10)
            
            // list of results
            if !onboardingViewModel.searchResults.isEmpty {
                List() {
                    ForEach(onboardingViewModel.searchResults, id: \.self) { location in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                // highlight tapped location
                                .foregroundStyle(location == onboardingViewModel.selectedLocation ? .accent : .clear)
                            VStack(alignment: .leading) {
                                Text("\(location.placemark.title ?? "")")
                                    // change text colour if selected
                                    .foregroundStyle(location == onboardingViewModel.selectedLocation ? .white : .primary)
                                    .lineLimit(2)
                            }
                            .padding()
                        }
                        .onTapGesture {
                            if onboardingViewModel.selectedLocation == location {
                                // unselect location
                                isLocationSelected = false
                                onboardingViewModel.selectedLocation = nil
                            } else {
                                // highlight selection
                                isLocationSelected = true
                                onboardingViewModel.selectedLocation = location
                            }
                        }
                        .onChange(of: searchInput) {
                            // unselect location
                            onboardingViewModel.selectedLocation = nil
                        }
                    }
                }
                .listStyle(.plain)
                .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20))  // extend list rows to edges of screen
                .scrollIndicators(.hidden)
            } else {
                // show error message is invalid input
                Text(onboardingViewModel.locationErrorPrompt)
                    .padding(.top, 20)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // confirm button
            Button("Confirm") {
                self.location = onboardingViewModel.selectedLocation?.placemark.title ?? ""
                dismiss()
            }
            .onboardingButtonStyle()
            // can't press button if haven't selected a location
            .disabled(onboardingViewModel.selectedLocation == nil)
        }
        .padding()
    }
}

//#Preview {
//    EditLocationView()
//}
