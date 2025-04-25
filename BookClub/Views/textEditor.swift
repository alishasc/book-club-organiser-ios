//
//  textEditor.swift
//  BookClub
//
//  Created by Alisha Carrington on 24/04/2025.
//

import SwiftUI

struct textEditor: View {
    @State var comment = ""
    
    var body: some View {
//        TextEditor(text: self.$text)
//        // make the color of the placeholder gray
//            .foregroundColor(self.text == "Type here" ? .gray : .primary)
//            .onAppear {
//                // remove the placeholder text when keyboard appears
//                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
//                    withAnimation {
//                        if self.text == "Type here" {
//                            self.text = ""
//                        }
//                    }
//                }
//                // put back the placeholder text if the user dismisses the keyboard without adding any text
//                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
//                    withAnimation {
//                        if self.text == "" {
//                            self.text = "Type here"
//                        }
//                    }
//                }
//            }
        
        VStack (alignment: .leading) {
                ZStack(alignment: .leading) {
                        TextEditor(text: $comment)
                                .frame(minHeight: 50)
                                
                        Text("Comment")
                                 .frame(width: 100, alignment: .leading)
                                 .foregroundColor(Color(.systemGray2))
                                 .padding(.top, -22)
                                 .padding(.leading, 5)
                                 .opacity(self.comment == "" ? 100 : 0)
                }
        }

    }
}

#Preview {
    textEditor()
}
