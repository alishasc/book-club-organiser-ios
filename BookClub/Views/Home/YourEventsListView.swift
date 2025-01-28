//
//  YourEventsListView.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

struct YourEventsListView: View {
    var body: some View {
        HStack {
            // cover image
            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 0)
                .foregroundStyle(.yellow)
                .frame(width: 100, height: 120)
                .padding(.trailing, 5)
            
            // text event info
            VStack(alignment: .leading) {
                Text("Book Club Name")
                    .fontWeight(.semibold)
                Text("Event Title")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Waterstones Piccadilly")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Mon 01 Jan - 12:00pm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("5 spaces left")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            Spacer()
            
            // icon - make it toggle to checkmark.circle
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
            
            Spacer()
        }
//        .frame(width: .infinity, height: 120)
        .background(.quaternary)
//        .shadow(color: .gray, radius: 5, x: 0, y: 5)
        .cornerRadius(10)
    }
}

#Preview {
    YourEventsListView()
}
