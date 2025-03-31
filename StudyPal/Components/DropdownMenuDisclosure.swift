//
//  DropdownMenuDisclosure.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/30/25.
//

import SwiftUI


struct DropdownMenuDisclosure<Content: View>: View {
    @State private var isExpanded = true
    public var title: String
    @ViewBuilder var options: Content
    
    var body: some View {
        
        DisclosureGroup(title, isExpanded: $isExpanded) {
            VStack(alignment: .center) {
                options
            }
        }
    }
}

#Preview {
    DropdownMenuDisclosure(title: "Select an Option") {
        Text("option 1")
        Text("option 2")
        Text("option 3")
    }
}
