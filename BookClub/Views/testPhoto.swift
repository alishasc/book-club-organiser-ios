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
        VStack {
            List {
                ForEach(Array(bookClubViewModel.allUserPictures), id: \.key) { userId, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                }
            }
        }
        .padding()
    }
}

#Preview {
    testPhoto()
}
