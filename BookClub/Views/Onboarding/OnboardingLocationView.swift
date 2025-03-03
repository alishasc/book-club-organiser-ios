//
//  OnboardingLocationView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

// choose location when sign up

import SwiftUI
import Firebase
import MapKit

struct OnboardingLocationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var onboardingViewModel: OnboardingViewModel
    @State private var searchInput: String = ""  // in textfield
    @State private var isLocationSelected: Bool = false  // when tap search result
    @State private var navigateToNavBar: Bool = false  // show NavBarView() if true
    
    var body: some View {
        NavigationStack {
            VStack {
                // titles
                VStack(alignment: .leading, spacing: 5) {
                    Text("Where are you located?")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Enter your location for better recommendations")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // textfield and list of results
                VStack {
                    // search bar/textfield
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .padding(.leading, 10)  // inside textfield
                        TextField("Search city, county or postcode", text: $searchInput)
                            .padding([.top, .bottom, .trailing], 10)  // inside textfield
                            .onSubmit {
                                Task {
                                    // check input is valid and get search results
                                    try await onboardingViewModel.locationFieldValidation(query: searchInput)
                                }
                            }
                    }
                    .background(.quinary)
                    .cornerRadius(10)
                    
                    // list - if there are search results returned from query
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
                                    isLocationSelected = true
                                    onboardingViewModel.selectedLocation = location
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
                }
                
                Spacer()
                
                // buttons
                VStack(spacing: 15) {
                    Button("Skip for now") {
                        Task {
                            try await authViewModel.saveOnboardingDetails(favouriteGenres: onboardingViewModel.selectedGenres, location: "")
                            
                            await authViewModel.fetchUser()
                        }
                        // show NavBarView() when press button
                        navigateToNavBar = true
                    }
                    .font(.subheadline)
                    
                    Button("Done") {
                        Task {
                            if let selectedLocation = onboardingViewModel.selectedLocation?.placemark.title {
                                try await authViewModel.saveOnboardingDetails(favouriteGenres: onboardingViewModel.selectedGenres, location: selectedLocation)
                                
                                await authViewModel.fetchUser()
                            }
                        }
                        navigateToNavBar = true
                    }
                    .onboardingButtonStyle()
                    // can't press button if haven't selected a location
                    .disabled(onboardingViewModel.selectedLocation == nil)
                    
                    Text("You can update your preferences from your profile")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 5)
                // triggers when press buttons
                .navigationDestination(isPresented: $navigateToNavBar) {
                    NavBarView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    OnboardingLocationView(onboardingViewModel: OnboardingViewModel()/*, signUpViewModel: SignUpViewModel()*/)
}
