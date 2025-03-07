//
//  testPhoto.swift
//  BookClub
//
//  Created by Alisha Carrington on 05/03/2025.
//

import SwiftUI

struct testPhoto: View {
    @StateObject var viewModel = PhotosPickerViewModel()
    
    var body: some View {
        VStack {
            if let coverImage = viewModel.coverImage {
                GeometryReader { geometry in
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 180)  // of image
                        .cornerRadius(10)
                }
                .frame(height: 180)  // constrict GeometryReader height
            }
        }
        .padding()
    }
}

#Preview {
    testPhoto()
}
