//
//  TagView.swift
//  BookClub
//
//  Created by Alisha Carrington on 28/01/2025.
//

// ref: https://github.com/happyiosdeveloper/swiftui-tagview

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
    @State private var totalHeight = CGFloat.zero       // << variant for ScrollView/List //    = CGFloat.infinity   // << variant for VStack
    
    @StateObject var onboardingViewModel: OnboardingViewModel
    @State private var genreCount: Int = 0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
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
                        tags[index].isSelected.toggle()
                        
                        // if genre has been selected
                        if tags[index].isSelected {
                            // add selection to array - can select up to 5
                            if self.genreCount < 5 {
                                onboardingViewModel.selectedGenres.append(tags[index].title)
                                self.genreCount += 1
                            }
                        } else {
                            // if untap the genre - remove it
                            if let selected = self.onboardingViewModel.selectedGenres.firstIndex(of: tags[index].title) {
                                onboardingViewModel.selectedGenres.remove(at: selected)
                                self.genreCount -= 1
                            }
                        }
                        print(onboardingViewModel.selectedGenres)
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func item(for text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .lineLimit(1)
            .background(isSelected ? .accent : .quaternaryHex)
            .frame(height: 30)
            .cornerRadius(10)
        //            .overlay(Capsule().stroke(.accent, lineWidth: 1))
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
