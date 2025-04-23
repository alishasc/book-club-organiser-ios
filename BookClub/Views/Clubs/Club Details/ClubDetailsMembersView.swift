//
//  ClubDetailsMembersView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

// moderator and members info

struct ClubDetailsMembersView: View {
    var moderatorInfo: [String:UIImage]
    var memberPics: [UIImage]
    
    var body: some View {
        HStack {
            // moderator info
            HStack(spacing: 15) {
                // moderator profile pic
                Image(uiImage: moderatorInfo.values.first ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                // moderator name
                VStack(alignment: .leading) {
                    Text("Created by")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(moderatorInfo.keys.first ?? "")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            // members info
            VStack(alignment: .trailing, spacing: 4) {
                if memberPics.count > 0 {
                    Text("\(memberPics.count) members")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No members yet")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                // member profile pics
                HStack(spacing: -5) {
                    ForEach(memberPics, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

//#Preview {
//    ClubDetailsMembersView()
//}
