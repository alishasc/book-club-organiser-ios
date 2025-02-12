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
    @Published var genreCount: Int = 0
    @Published var searchResults: [MKMapItem] = []
    @Published var locationErrorPrompt: String = ""  // error message if invalid input
    @Published var selectedLocation: MKMapItem?
    
    // tagview genres
    let topGenres: [String] = ["Contemporary", "Fantasy", "Mystery", "Romance", "Thriller"]
    let fictionGenres: [String] = ["Children's Fiction", "Classics", "Graphic Novels", "Historical Fiction", "Horror", "LGBTQ+", "Myths & Legends", "Poetry", "Science-Fiction", "Short Stories", "Young Adult"]
    let nonFictionGenres: [String] = ["Art & Design", "Biography", "Business", "Education", "Food", "History", "Humour", "Music", "Nature & Environment", "Personal Growth", "Politics", "Psychology", "Religion & Spirituality", "Science", "Technology", "Sports", "Travel", "True Crime", "Wellness"]
    
    func locationFieldValidation(query: String) async throws {
        // check whether search is valid before calling getSearchResults()
        if query.isEmpty {
            self.searchResults = []  // reset array
            print("empty string")
            locationErrorPrompt = ""
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
                locationErrorPrompt = "No search results found. Please try again"
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
            locationErrorPrompt = "Location not found. Please try again."
        }
    }
    
    // select/deselect genres in tagviews
    func selectGenre(genre: String, isSelected: Bool) {
        if isSelected {
            if genreCount < 5 {
                selectedGenres.append(genre)
                genreCount += 1
            }
        } else {
            if let selectedGenre = selectedGenres.firstIndex(of: genre) {
                selectedGenres.remove(at: selectedGenre)
                genreCount -= 1
            }
        }
    }
}
