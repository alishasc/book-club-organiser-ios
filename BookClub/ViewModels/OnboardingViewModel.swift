//
//  OnboardingViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import Foundation
import MapKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var selectedGenres: [String] = []
    @Published var searchResults: [MKMapItem] = []
    @Published var locationPrompt: String = ""  // error message if invalid input
    @Published var selectedLocation: MKMapItem?
    
    func locationFieldValidation(query: String) async throws {
        // check whether search is valid before calling getSearchResults()
        if query.isEmpty {
            self.searchResults = []  // reset array
            print("empty string")
            locationPrompt = ""
            return
        } else {
            // remove trailing whitespace
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // check for invalid characters
            let queryRegex = "^[a-zA-Z0-9\\-\\'\\’\\s]+$"
            let queryTest = NSPredicate(format: "SELF MATCHES %@", queryRegex)
            print(queryTest.evaluate(with: trimmedQuery))
            
            // is NSPredicate test passes then get search results for the query with whitespace removed
            if queryTest.evaluate(with: trimmedQuery) {
                try await getSearchResults(query: trimmedQuery)
            } else {
                // change this
                self.searchResults = []
                print("invalid input")
                locationPrompt = "No search results found. Please try again"
                return
            }
        }
    }
    
    func getSearchResults(query: String) async throws {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        
        if let response = try? await search.start() {
            let items = response.mapItems
            // reset results array each search
            self.searchResults = []
            
            for item in items {
                if searchResults.count < 10 {
                    self.searchResults.append(item)
                } else {
                    break
                }
            }
        } else {
            print("invalid search")
            self.searchResults = []  // don't show any search results in list view
            locationPrompt = "Location not found. Please try again."
        }
    }
}
