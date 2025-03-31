//
//  CategoryScrollHorizontal.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/30/25.
//

import SwiftUI

struct CategoryUIModel {
    var name: String
    var color: Color
    var selected: Bool = false
}

struct CategoryScrollHorizontal: View {
    
    @Binding var categories: [CategoryUIModel]
    
    var body: some View {
        
        if categories.count > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories, id: \.name) { category in
                        HStack {
                            Text(category.name)
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(category.color)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 2)
                        )
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

#Preview {
    @Previewable @State var categories: [CategoryUIModel] = {
        var cat1 = CategoryUIModel(name: "Category 1", color: Color.blue)
        var cat2 = CategoryUIModel(name: "Category 2", color: Color.red)
        var cat3 = CategoryUIModel(name: "Category 3", color: Color.green)
        var cat4 = CategoryUIModel(name: "Category 4", color: Color.yellow)
        var cat5 = CategoryUIModel(name: "Category 5", color: Color.orange)
        
        
        return [
            cat1, cat2, cat3, cat4, cat5
        ]
    }()
    
    CategoryScrollHorizontal(categories: $categories)
}
