//
//  ClubDetailsMembersView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

// moderator and members info

struct ClubDetailsMembersView: View {
    var moderatorName: String
//    var moderatorPic: Image
//    var memberPics: [Image]
    
    var body: some View {
        HStack {
            // mooderator info
            HStack(spacing: 15) {
                // moderator profile pic
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.customYellow)
                
                // moderator name
                VStack(alignment: .leading) {
                    Text("Created by")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(moderatorName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            // members info
            VStack(alignment: .trailing, spacing: 4) {
                Text("no. of members")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                // member profile pics
                HStack(spacing: -5) {
                    // add ForEach loop here for club members? max 4 pics
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customYellow)
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customGreen)
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customPink)
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.customBlue)
                }
            }
        }
    }
}

//#Preview {
//    ClubDetailsMembersView()
//}
