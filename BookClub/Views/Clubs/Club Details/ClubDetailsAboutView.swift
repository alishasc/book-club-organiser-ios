//
//  ClubDetailsAboutView.swift
//  BookClub
//
//  Created by Alisha Carrington on 13/02/2025.
//

import SwiftUI

struct ClubDetailsAboutView: View {
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.subheadline)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.quaternaryHex.opacity(0.6))
                )
        }
    }
}

#Preview {
    ClubDetailsAboutView(description: "A book club for fantasy lovers who enjoy exploring captivating worlds, complex characters, and thought provoking stories. Join us for engaging discussions and discover new adventures in every book!")
}
