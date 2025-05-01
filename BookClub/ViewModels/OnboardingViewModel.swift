//
//  OnboardingViewModel.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import Foundation
import MapKit

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var selectedGenres: [String] = []
    @Published var searchResults: [MKMapItem] = []
    @Published var locationErrorPrompt: String = ""  // error message if invalid search query
    @Published var selectedLocation: MKMapItem?  // when tap location from search result list
    
    // tagview genres
    let topGenres: [String] = ["Contemporary", "Fantasy", "Mystery", "Romance", "Thriller"]
    let fictionGenres: [String] = ["Children's Fiction", "Classics", "Graphic Novels", "Historical Fiction", "Horror", "LGBTQ+", "Myths & Legends", "Poetry", "Science-Fiction", "Short Stories", "Young Adult"]
    let nonFictionGenres: [String] = ["Art & Design", "Biography", "Business", "Education", "Food", "History", "Humour", "Music", "Nature & Environment", "Personal Growth", "Politics", "Psychology", "Religion & Spirituality", "Science", "Technology", "Sports", "Travel", "True Crime", "Wellness"]
    
    // check whether location search query is valid before calling getSearchResults()
//    func locationFieldValidation(query: String) async throws {
//        self.searchResults = []
//
//        if query.isEmpty {
//            // reset results and error message
//            locationErrorPrompt = ""
//            return
//        } else {
//            // remove trailing & leading whitespace
//            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            // check string only has letters, numbers, hyphens, apostrophes and spaces
////            let queryTest = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9\\-\\'\\’\\s]+$")
//            
//            // check the now trimmed query matches the regex pattern
//            do {
//                try await getSearchResults(query: trimmedQuery)
//            } catch {
//                // invalid search query
//                locationErrorPrompt = "No search results found. Please try again."
//                return
//            }
//        }
//    }
    
    func getSearchResults(query: String) async throws {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        
        if let response = try? await search.start() {
            let items = response.mapItems
            // reset search results each search
            self.searchResults = []
            
            // add up to 15 locations to results array
            for item in items {
                if self.searchResults.count < 15 {
                    self.searchResults.append(item)
                } else {
                    break
                }
            }
        } else {
            self.searchResults = []  // don't show any search results in list view
            locationErrorPrompt = "No search results found. Please try again."
        }
    }
    
    // select/deselect genre tags
    func selectGenre(genre: String, isSelected: Bool) {
        if isSelected {
            if selectedGenres.count < 5 {
                selectedGenres.append(genre)
            }
        } else {
            if let selectedGenre = selectedGenres.firstIndex(of: genre) {
                selectedGenres.remove(at: selectedGenre)
            }
        }
    }
}
