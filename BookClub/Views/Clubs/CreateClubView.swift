//
//  CreateClubView.swift
//  BookClub
//
//  Created by Alisha Carrington on 06/02/2025.
//

import SwiftUI

struct CreateClubView: View {
    let genreChoices: [String] = ["Art & Design", "Biography", "Business", "Children's Fiction", "Classics", "Contemporary", "Education", "Fantasy", "Food", "Graphic Novels", "Historical Fiction", "History", "Horror", "Humour", "LGBTQ+", "Mystery", "Music", "Myths & Legends", "Nature & Environment", "Personal Growth", "Poetry", "Politics", "Psychology", "Religion & Spirituality", "Romance", "Science", "Science-Fiction", "Short Stories", "Sports", "Technology", "Thriller", "Travel", "True Crime", "Wellness", "Young Adult"]
    let meetingTypeChoices: [String] = ["Online", "In-Person"]
    
    // textfields
    enum Field: Hashable {
        case clubName, description
    }
    
    @StateObject var bookClubViewModel: BookClubViewModel
    @FocusState private var focusedField: Field?  // to navigate between textfields
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var wordCount: Int = 0
    @State private var genre: String = "Art & Design"
    @State private var meetingType: String = "Online"
    @State private var isPublic: Bool = false
    let creationDate: Date = Date().addingTimeInterval(0)  // current date and time
    @State private var goToClubDetails: Bool = false
    
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
                
                ViewTemplates.textField(placeholder: "Club name", input: $name, isSecureField: false)
                    .focused($focusedField, equals: .clubName)
                    .onSubmit {
                        focusedField = .description
                    }
                
                // change submit label do 'done'
                ViewTemplates.textField(placeholder: "Description", input: $description, isSecureField: false)
                    .focused($focusedField, equals: .description)
                    .onSubmit {
                        focusedField = nil
                    }
                    .onChange(of: description) {
                        wordCount = getWordCount(str: description)
                        
                        if wordCount == 41 {
                            // can't add more than 40 words
                            description.removeLast()
                        }
                    }
                
                HStack {
                    Spacer()
                    Text("\(wordCount)/40")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("What genre best describes your club?")
                        .fontWeight(.medium)
                    Spacer()
                    Picker("", selection: $genre) {
                        ForEach(genreChoices, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                HStack {
                    Text("Where will your club meet?")
                        .fontWeight(.medium)
                    Spacer()
                    Picker("Where will your club meet?", selection: $meetingType) {
                        ForEach(meetingTypeChoices, id: \.self) {
                            Text($0)
                        }
                    }
                    .offset(x: 10)
                }
            }
            .padding(.bottom, 15)
            
            Toggle(isOn: $isPublic) {
                Text("Make club public")
                    .fontWeight(.medium)
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
                    // save new club details to firebase
                    Task {
                        try await bookClubViewModel.saveNewClub(name: name, description: description, genre: genre, meetingType: meetingType, isPublic: isPublic, creationDate: creationDate)
                    }
                    
                    // show the club details for the new club after pressing confirm
//                    goToClubDetails = true
                }
                .disabled(name.isEmpty || description.isEmpty)  // can't press if form not filled
            }
        }
//        .navigationDestination(isPresented: $goToClubDetails) {
//            BookClubDetailsView(bookClubViewModel: bookClubViewModel)
//        }
    }
}

// move func to view model
// ref: https://stackoverflow.com/questions/42822838/how-to-get-the-number-of-real-words-in-a-text-in-swift
func getWordCount(str: String) -> Int {
    let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
    let components = str.components(separatedBy: chararacterSet)
    let words = components.filter { !$0.isEmpty }
    return words.count
}

#Preview {
    CreateClubView(bookClubViewModel: BookClubViewModel())
}
