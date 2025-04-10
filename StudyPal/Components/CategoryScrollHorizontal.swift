//
//  CategoryScrollHorizontal.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/30/25.
//

import SwiftUI

struct CategoryUIModel: Identifiable {
    var id = UUID()
    var name: String
    var color: Color
    var selected: Bool = false
}

struct CategoryScrollHorizontal: View {
    
    @Binding var categories: [CategoryUIModel]
    @Binding var selectedCategory: String?
    
    var body: some View {
        
        if categories.count > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<categories.count, id: \.self) { index in
                        HStack {
                            Text(categories[index].name)
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(categories[index].color)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(categories[index].selected ? Color.gray.opacity(0.3) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .onTapGesture {
                            // Deselect currently selected category if any
                            if let selectedIndex = categories.firstIndex(where: { $0.selected }) {
                                categories[selectedIndex].selected = false
                            }
                            
                            // Toggle selected status for tapped category
                            categories[index].selected.toggle()
                            
                            // Update selected category name
                            selectedCategory = categories[index].selected ? categories[index].name : nil
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        } else {
            HStack {
                Text("No Categories Yet!")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

// Preview for development
struct CategoryScrollHorizontal_Previews: PreviewProvider {
    static var previews: some View {
        @State var categories: [CategoryUIModel] = [
            CategoryUIModel(name: "Category 1", color: Color.blue),
            CategoryUIModel(name: "Category 2", color: Color.red),
            CategoryUIModel(name: "Category 3", color: Color.green),
            CategoryUIModel(name: "Category 4", color: Color.yellow),
            CategoryUIModel(name: "Category 5", color: Color.orange)
        ]
        @State var selectedCategory: String? = nil
        
        return CategoryScrollHorizontal(categories: $categories, selectedCategory: $selectedCategory)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
