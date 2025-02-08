//
//  CreateClubView.swift
//  BookClub
//
//  Created by Alisha Carrington on 06/02/2025.
//

import SwiftUI

struct CreateClubView: View {
    @State private var clubName: String = ""
    @State private var description: String = ""
    @State private var genre: [String] = []
    @State private var location: String = ""
    @State private var isClubPublic: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Cover image")
                    .fontWeight(.medium)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 180)
                        .foregroundColor(.quaternaryHex)
                    Button {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    } label: {
                        Label("Add cover image", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 60))
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
                
                ViewTemplates.loginTextField(placeholder: "Club name", input: $clubName, isSecureField: false)
                ViewTemplates.loginTextField(placeholder: "Description", input: $description, isSecureField: false)
                
                Text("Genre")
                    .fontWeight(.medium)
                
                Text("Where will your club meet?")
                    .fontWeight(.medium)
            }
            .padding(.bottom, 15)
            
            VStack(alignment: .leading) {
                Toggle(isOn: $isClubPublic) {
                    Text("Make club public")
                        .fontWeight(.medium)
                }
                Text("Making your club public allows anyone to join.")
                    .font(.subheadline)
            }
            .padding()
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
        }
        .padding()
        .navigationTitle("Create a New Club")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                .disabled(true)  // enable when form filled
            }
        }
    }
}

#Preview {
    CreateClubView()
}
