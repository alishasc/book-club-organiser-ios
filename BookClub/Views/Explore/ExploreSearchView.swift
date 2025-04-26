//
//  ExploreSearchView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/04/2025.
//

import SwiftUI

struct ExploreSearchView: View {
    @State private var searchInput: String = ""

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 10)  // inside textfield
                TextField("Search club name or genre", text: $searchInput)
                    .padding([.top, .bottom, .trailing], 10)  // inside textfield
            }
            .foregroundStyle(.black)
            .background(.quinary)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Search")
    }
}

#Preview {
    ExploreSearchView()
}
