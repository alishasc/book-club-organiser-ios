//
//  ClubDetailsPRView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct ClubDetailsPRView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Previously Read")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Image(/*@START_MENU_TOKEN@*/"Image Name"/*@END_MENU_TOKEN@*/)  // or async image??
                        .resizable()
                        .frame(width: 100, height: 142)
                        .background(.customBlue)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customBlue.opacity(0.3))
                        )
                    Image(/*@START_MENU_TOKEN@*/"Image Name"/*@END_MENU_TOKEN@*/)  // or async image??
                        .resizable()
                        .frame(width: 100, height: 142)
                        .background(.customYellow)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customYellow.opacity(0.3))
                        )
                    Image(/*@START_MENU_TOKEN@*/"Image Name"/*@END_MENU_TOKEN@*/)  // or async image??
                        .resizable()
                        .frame(width: 100, height: 142)
                        .background(.customPink)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.customPink.opacity(0.3))
                        )
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ClubDetailsPRView()
}
