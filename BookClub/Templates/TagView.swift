//
//  TagView.swift
//  BookClub
//
//  Created by Alisha Carrington on 28/01/2025.
//

// ref: https://github.com/happyiosdeveloper/swiftui-tagview
// for onboarding genre tags

import SwiftUI

struct TagViewItem: Hashable {
    var title: String
    var isSelected: Bool
    
    static func == (lhs: TagViewItem, rhs: TagViewItem) -> Bool {
        return lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(isSelected)
    }
}

struct TagView: View {
    @State var tags: [TagViewItem]
    @State private var totalHeight = CGFloat.zero
    
    @StateObject var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(tags.indices, id: \.self) { index in
                item(for: tags[index].title, isSelected: tags[index].isSelected)
                    .padding([.horizontal, .vertical], 3)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tags[index].title == self.tags.last!.title {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if tags[index].title == self.tags.last!.title {
                            height = 0 // last item
                        }
                        return result
                    })
                    .onTapGesture {
                        // if unselected and count < 5
                        if !tags[index].isSelected && onboardingViewModel.selectedGenres.count < 5 {
                            tags[index].isSelected.toggle()
                        } else if tags[index].isSelected {
                            // unselect if already selected
                            tags[index].isSelected.toggle()
                        }
                        
                        // function to add tapped genre to array
                        onboardingViewModel.selectGenre(genre: tags[index].title, isSelected: tags[index].isSelected)
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    // tag styling
    private func item(for text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .lineLimit(1)
            .background(isSelected ? .accent : .quaternaryHex)
            .frame(height: 30)
            .cornerRadius(10)
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

//#Preview {
//    TagView()
//}
