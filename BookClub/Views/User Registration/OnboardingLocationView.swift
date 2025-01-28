//
//  OnboardingLocationView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI
import MapKit
import Firebase

struct OnboardingLocationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var onboardingViewModel: OnboardingViewModel
    @StateObject var signUpViewModel: SignUpViewModel
    @State private var searchInput: String = ""  // in textfield
    @State private var isLocationSelected: Bool = false  // true when tap search result from list
    
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
                                    // check input is valid
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
                                    // highlight tapped option only
                                        .foregroundStyle(location == onboardingViewModel.selectedLocation ? .orange : .clear)
                                    VStack(alignment: .leading) {
                                        Text("\(location.placemark.title ?? "")")
                                            .lineLimit(2)
                                    }
                                    .padding()
                                }
                                .onTapGesture {
                                    if isLocationSelected == false {
                                        onboardingViewModel.selectedLocation = location
                                    } else {
                                        onboardingViewModel.selectedLocation = nil
                                    }
                                    print(onboardingViewModel.selectedLocation ?? "no location")
                                }
                                // keep?
                                .onChange(of: searchInput) {
                                    // reset properties when change search query
                                    isLocationSelected = false
                                    onboardingViewModel.selectedLocation = nil
                                    print(onboardingViewModel.selectedLocation ?? "no location")
                                }
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        // invalid/empty input
                        Text(onboardingViewModel.locationPrompt)
                            .padding(.top, 20)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // buttons
                Group {
                    NavigationLink(destination: NavBarView()) {
                        Button("Done") {
                            // call function to save location to User - add to firebase!
//                            authViewModel.addNewUser(name: signUpViewModel.name, email: signUpViewModel.email, favouriteGenres: onboardingViewModel.selectedGenres, location: <#T##GeoPoint?#>)
                        }
                        .fontWeight(.medium)
                        .padding(.vertical, 10)  // inside button
                        .background(
                            Capsule()
                                .frame(minWidth: 240)
                                .foregroundStyle(.yellow)
                        )
                        .padding(.bottom, 10)  // under button
                    }
                    .disabled(onboardingViewModel.selectedLocation == nil)
                    
                    NavigationLink("Skip for now", destination: NavBarView())
                        .font(.subheadline)
                    
                    Text("You can update your preferences from your profile")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
}


#Preview {
    OnboardingLocationView(onboardingViewModel: OnboardingViewModel(), signUpViewModel: SignUpViewModel())
}
