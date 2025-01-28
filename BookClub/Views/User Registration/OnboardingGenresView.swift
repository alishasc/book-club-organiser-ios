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
    let fictionGenres: [String] = ["Children's Fiction", "Classics", "Graphic Novels", "Historical Fiction", "Horror", "LGBTQ+", "Myths & Legends", "Poetry", "Science-Fiction", "Short Stories", "Young Adult"]
    let nonFictionGenres: [String] = ["Art & Design", "Biography", "Business", "Education", "Food", "History", "Humour", "Music", "Nature & Environment", "Personal Growth", "Politics", "Psychology", "Religion & Spirituality", "Science", "Technology", "Sports", "Travel", "True Crime", "Wellness"]
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("What are your favourite genres?")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("You can select up to 5 genres")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Top Genres")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("options here")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Fiction")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("options here")
                    Button("View more...") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .foregroundStyle(.tint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Non-Fiction")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("options here")
                    Button("View more...") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }
                    .foregroundStyle(.tint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Group {
                    NavigationLink(destination: OnboardingLocationView(onboardingViewModel: OnboardingViewModel(), signUpViewModel: SignUpViewModel())) {
                        Text("Next")
                            .foregroundStyle(.tint)
                    }
                    // button disabled until choose genre
//                    .disabled(onboardingViewModel.selectedGenres.isEmpty)
                    
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
