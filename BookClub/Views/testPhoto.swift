//
//  testPhoto.swift
//  BookClub
//
//  Created by Alisha Carrington on 05/03/2025.
//

import SwiftUI

struct testPhoto: View {
    @EnvironmentObject var bookClubViewModel: BookClubViewModel
    
    var body: some View {
//        let coverImage = bookClubViewModel.coverImages[]

        VStack {
            List {
                ForEach(Array(bookClubViewModel.coverImages), id: \.key) { bookClubId, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 200)
                }
            }
            
//            Image(uiImage: coverImage)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 300, height: 200)
        }
        .padding()
    }
}

#Preview {
    testPhoto()
}
