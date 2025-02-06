//
//  OnboardingGenresView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct OnboardingGenresView: View {
    @StateObject var onboardingViewModel: OnboardingViewModel
    @State private var showFiction: Bool = false
    @State private var showNonFiction: Bool = false

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
//                            if !showFiction {
//                                TagView(tags: onboardingViewModel.fictionGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: onboardingViewModel)
//                                Button("View more...") {
//                                    withAnimation(.easeIn) {
//                                        showFiction = true
//                                    }
//                                }
//                                .font(.subheadline)
//                                .foregroundStyle(.tint)
//                            } else {
                                TagView(tags: onboardingViewModel.extraFiction.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: onboardingViewModel)
//                            }
                        }
                        
                        // non-fiction
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Non-Fiction")
                                .font(.title2)
                                .fontWeight(.semibold)
//                            if !showNonFiction {
//                                TagView(tags: onboardingViewModel.nonFictionGenres.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: onboardingViewModel)
//                                Button("View more...") {
//                                    withAnimation(.easeIn) {
//                                        showNonFiction = true
//                                    }
//                                }
//                                .font(.subheadline)
//                                .foregroundStyle(.tint)
//                            } else {
                                TagView(tags: onboardingViewModel.extraNonFiction.map { TagViewItem(title: $0, isSelected: false) }, onboardingViewModel: onboardingViewModel)
//                            }
                        }
                    }
                }
                
                VStack(spacing: 15) {
                    NavigationLink(destination: OnboardingLocationView(onboardingViewModel: onboardingViewModel, signUpViewModel: SignUpViewModel())) {
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
