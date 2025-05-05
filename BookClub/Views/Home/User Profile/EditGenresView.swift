//
//  EditGenresView.swift
//  BookClub
//
//  Created by Alisha Carrington on 20/04/2025.
//

import SwiftUI

struct EditGenresView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var genreChoices: [String]
    @Binding var favouriteGenres: [String]
    
    var body: some View {
        VStack {
            // current genres
            VStack(alignment: .leading) {
                Text("Genres selected:")
                    .fontWeight(.medium)
                Text(favouriteGenres.sorted().joined(separator: ", "))
                    .multilineTextAlignment(.leading)
                Divider()
            }
            .padding([.top, .horizontal])
            
            List(genreChoices, id: \.self) { genre in
                HStack {
                    Text(genre)
                    Spacer()
                    if favouriteGenres.contains(genre) {
                        Image(systemName: "checkmark")
                    }
                }
                // add logic to toggle genre
                .onTapGesture {
                    favouriteGenres = authViewModel.toggleGenre(favouriteGenres: favouriteGenres, genre: genre)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
    }
}

//#Preview {
//    EditGenresView()
//}
