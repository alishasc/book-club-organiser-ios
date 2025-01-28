//
//  ExploreView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

import SwiftUI

struct ExploreView: View {
    let genreFilter: [String] = ["All", "Contemporary", "Fantasy", "Mystery", "Romance", "Thriller"]
    @State private var searchInput: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Explore")
                    .font(.largeTitle).bold()
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 10)  // inside textfield
                    TextField("Search club name, genre, location", text: $searchInput)
                        .padding([.top, .bottom, .trailing], 10)  // inside textfield
                }
                .background(.quinary)
                .cornerRadius(10)
                
                // circle genre filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(genreFilter.indices, id: \.self) { filter in
                            VStack {
                                Circle()
                                    .frame(width: 90, height: 90)
                                    .foregroundStyle(.quinary)
                                Text(genreFilter[filter])
                                    .font(.footnote)
                            }
                        }
                    }
                }
                
                // popular clubs
                VStack(alignment: .leading, spacing: 10) {
                    Text("Popular Clubs")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                        }
                    }
                }
                
                // online book clubs
                VStack(spacing: 10) {
                    HStack {
                        Text("Online Book Clubs")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                            Text("View all")
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                        }
                    }
                }
                
                // in-person book clubs
                VStack(spacing: 10) {
                    HStack {
                        Text("In-Person Book Clubs")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                            Text("View all")
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                            ViewTemplates.bookClubRow(clubName: "Book Club Name")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ExploreView()
}
