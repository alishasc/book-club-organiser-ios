//
//  EditGenresView.swift
//  BookClub
//
//  Created by Alisha Carrington on 20/04/2025.
//

import SwiftUI

struct EditGenresView: View {
    var genreChoices: [String]
    @Binding var favouriteGenres: [String]
    
    var body: some View {
        VStack {
            // current genres
            HStack {
                Text("Genres selected:")
                    .fontWeight(.medium)
                Text(favouriteGenres.joined(separator: ", "))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
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
                    favouriteGenres = toggleGenre(favouriteGenres: favouriteGenres, genre: genre)
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    EditGenresView()
//}
