//
//  OnboardingGenresView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct OnboardingGenresView: View {
    @StateObject var onboardingViewModel: OnboardingViewModel
    
    let topGenres: [String] = ["Contemporary", "Fantasy", "Mystery", "Romance", "Thriller"]
    let fictionGenres: [String] = ["Children's Fiction", "Classics", "Graphic Novels", "Historical Fiction", "Horror", "LGBTQ+", "Myths & Legends", "Poetry"]
    let extraFiction: [String] = ["Science-Fiction", "Short Stories", "Young Adult"]
    let nonFictionGenres: [String] = ["Art & Design", "Biography", "Business", "Education", "Food", "History", "Humour", "Music", "Nature & Environment"]
    let extraNonFiction: [String] = ["Personal Growth", "Politics", "Psychology", "Religion & Spirituality", "Science", "Technology", "Sports", "Travel", "True Crime", "Wellness"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("What are your favourite genres?")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("You can select up to 5 genres")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Top Genres")
                        .font(.title2)
                        .fontWeight(.semibold)
                    TagView(tags: topGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: OnboardingViewModel())
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Fiction")
                        .font(.title2)
                        .fontWeight(.semibold)
                    TagView(tags: fictionGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: OnboardingViewModel())
                    Button("View more...") {
                        
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tint)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Non-Fiction")
                        .font(.title2)
                        .fontWeight(.semibold)
                    TagView(tags: nonFictionGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: OnboardingViewModel())
                    Button("View more...") {
                        
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tint)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    NavigationLink(destination: OnboardingLocationView(onboardingViewModel: OnboardingViewModel(), signUpViewModel: SignUpViewModel())) {
                        Text("Next")
                            .onboardingButtonStyle()
                    }
                    // button disabled until choose genre
                    .disabled(onboardingViewModel.selectedGenres.isEmpty)
                    
                    Text("You can update your preferences from your profile")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .padding()
        }
    }
}

#Preview {
    OnboardingGenresView(onboardingViewModel: OnboardingViewModel())
}
