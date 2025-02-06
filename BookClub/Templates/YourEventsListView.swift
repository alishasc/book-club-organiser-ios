//
//  YourEventsListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct YourEventsListView: View {
    var clubName: String
    var clubRead: String
    var location: String
    var date: String
    var time: String
    var spacesLeft: Int
    //    var eventType: String  // whether event is online/in-person/created
    //    var isEventsPage: Bool  // ???
    
    var body: some View {
        ZStack {
            // for line along bottom - in background
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.customGreen)
                .frame(height: 120)
                .offset(y: 5)
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
            
            HStack {
                // image
                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 0)
                    .foregroundStyle(.gray)
                    .frame(width: 110)
                    .padding(.trailing, 5)
                
                // text event info
                VStack(alignment: .leading) {
                    Text(clubName)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text(clubRead)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text(location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text("\(date) - \(time)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(spacesLeft) spaces left")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    Spacer()
                    // icon - make it toggle to checkmark.circle
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.accent)
                    Spacer()
                    Text("Online")
                        .font(.caption2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            .customGreen
                                .opacity(0.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .offset(x: -7, y: -7)
                }
            }
            .background(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal, 2)  // to show drop shadow on edges
    }
}

#Preview {
    YourEventsListView(clubName: "Fantasy Book Club", clubRead: "Onyx Storm", location: "Waterstones Piccadilly", date: "Mon 01 Jan", time: "12:00", spacesLeft: 5)
}
