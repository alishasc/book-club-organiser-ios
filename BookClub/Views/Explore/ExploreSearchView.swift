//
//  ExploreSearchView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/04/2025.
//

// MARK: ref - https://www.swiftyplace.com/blog/swiftui-search-bar-best-practices-and-examples#Creating_a_Scope_Bar_to_Filter_Results

import SwiftUI
import FirebaseAuth

struct ExploreSearchView: View {
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Recent")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("Clear all") {
                        //
                    }
                }
                
                List {
                    ForEach(bookClubViewModel.searchExplorePage) { club in
                        ClubsCardView(coverImage: bookClubViewModel.coverImages[club.id] ?? UIImage(), clubName: club.name, clubGenre: club.genre)
                            .background(
                                // hide navigation link arrows
                                NavigationLink("", destination: ClubHostView(bookClub: club, isModerator: club.moderatorId == Auth.auth().currentUser?.uid, isMember: bookClubViewModel.checkIsMember(bookClub: club)))
                                    .opacity(0)
                            )
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
                    }
                    .listRowSeparator(.hidden, edges: .all)
                }
                .listRowSpacing(2)
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .navigationTitle("Search Book Clubs")
                .searchable(text: $bookClubViewModel.explorePageQuery, placement: .navigationBarDrawer(displayMode:.always), prompt: "Search club name or genre")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ExploreSearchView()
        .environmentObject(BookViewModel())
}
