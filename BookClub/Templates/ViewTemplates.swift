//
//  ViewTemplates.swift
//  BookClub
//
//  Created by Alisha Carrington on 26/01/2025.
//

import SwiftUI

class ViewTemplates {
    static func textField(placeholder: String, input: Binding<String>, isSecureField: Bool) -> some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .fontWeight(.medium)
            TextField("", text: input)
            Divider()
        }
        .disableAutocorrection(true)
    }
    
    static func signupTextField(placeholder: String, input: Binding<String>, isSecureField: Bool, prompt: String) -> some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .fontWeight(.medium)
            TextField("", text: input)
            Divider()
            Text(prompt)
                .foregroundStyle(.red)
                .font(.footnote)
        }
        .disableAutocorrection(true)
    }
    
    static func passwordSecureField(placeholder: String, input: Binding<String>, showPassword: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .fontWeight(.medium)
            
            if showPassword.wrappedValue {
                TextField("", text: input)
            } else {
                SecureField("", text: input)
            }
            
            Divider()
        }
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .submitLabel(.done)
    }
    
    // on home and explore pages
    static func bookClubRow(coverImage: UIImage, clubName: String, clubGenre: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(uiImage: coverImage)
                .resizable()
                .scaledToFill()
                .frame(width: 240, height: 150)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
            
            VStack(alignment: .leading) {
                Text(clubName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Text(clubGenre)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .padding([.leading, .bottom], 15)
        }
    }
    
    static func bookClubExploreList(coverImage: UIImage, clubName: String, clubGenre: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geometry in
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: 150)
                    .cornerRadius(10)
//                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: -2)  // top shadow
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)  // bottom shadow
            }
            .frame(height: 150)
            
            VStack(alignment: .leading) {
                Text(clubName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Text(clubGenre)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .padding([.leading, .bottom], 15)
        }
    }
    
    struct loginSignupButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundStyle(.white)  // text colour
                .padding(.vertical, 10)
                .frame(minWidth: 340)
                .background(.tint)
                .clipShape(Capsule())
        }
    }
    
    struct onboardingButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundStyle(.white)  // text colour
                .padding(.vertical, 10)
                .frame(minWidth: 240)
                .background(.tint)
                .clipShape(Capsule())
        }
    }
    
    static func dateFormatter(dateAndTime: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd MMM - hh:mm"  // Mon 03 Mar - 05:00
        return formatter.string(from: dateAndTime)
    }
    
    static func eventSheetDateFormatter(dateAndTime: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd MMMM"  // Friday 21 March
        return formatter.string(from: dateAndTime)
    }
    
    static func eventSheetTimeFormatter(dateAndTime: Date, duration: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"  // 03:44pm
        // add duration to time to get end time
        let startTime = formatter.string(from: dateAndTime)
        let endTime = formatter.string(from: dateAndTime.adding(minutes: duration))
        
        return "\(startTime) - \(endTime)"
    }
}

extension View {
    func loginSignupButtonStyle() -> some View {
        modifier(ViewTemplates.loginSignupButtonModifier())
    }
}

extension View {
    func onboardingButtonStyle() -> some View {
        modifier(ViewTemplates.onboardingButtonModifier())
    }
}

// code ref: https://www.hackingwithswift.com/forums/swiftui/adding-time-in-swiftui/12178
extension Date {
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
}
