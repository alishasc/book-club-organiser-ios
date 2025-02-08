//
//  EventDatesView.swift
//  BookClub
//
//  Created by Alisha Carrington on 01/02/2025.
//

import SwiftUI

struct EventDatesView: View {
    var dateStr: String
    var dateInt: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 42, height: 75)
                .foregroundStyle(.quinary)
            
            VStack {
                Group {
                    Text("\(dateStr)")
                    Text("\(dateInt)")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                
                HStack(spacing: 3) {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(.customYellow)
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(.customGreen)
//                    Circle()
//                        .frame(width: 10, height: 10)
//                        .foregroundStyle(.customPink)
                }
            }
        }
    }
}

#Preview {
    EventDatesView(dateStr: "Tue", dateInt: 2)
}
