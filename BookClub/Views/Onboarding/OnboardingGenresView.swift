//
//  OnboardingGenresView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

// pick favourite genres when sign up

import SwiftUI

struct OnboardingGenresView: View {
    @StateObject var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // titles and genre count
                VStack(alignment: .leading, spacing: 5) {
                    Text("What are your favourite genres?")
                        .font(.title)
                        .fontWeight(.semibold)
                    HStack {
                        Text("You can select up to 5 genres")
                        Spacer()
                        Text("\(onboardingViewModel.selectedGenres.count)/5")
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // genres
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        // top genres
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Top Genres")
                                .font(.title2)
                                .fontWeight(.semibold)
                            TagView(tags: onboardingViewModel.topGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: onboardingViewModel)
                        }
                        
                        // fiction
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Fiction")
                                .font(.title2)
                                .fontWeight(.semibold)
                            TagView(tags: onboardingViewModel.fictionGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: onboardingViewModel)
                        }
                        
                        // non-fiction
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Non-Fiction")
                                .font(.title2)
                                .fontWeight(.semibold)
                            TagView(tags: onboardingViewModel.nonFictionGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: onboardingViewModel)
                        }
                    }
                }
                
                // next button
                VStack(spacing: 15) {
                    NavigationLink(destination: OnboardingLocationView(onboardingViewModel: onboardingViewModel)) {
                        Text("Next")
                            .onboardingButtonStyle()
                    }
                    // button disabled if no genres chosen
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
