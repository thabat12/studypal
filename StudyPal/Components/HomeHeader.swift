//
//  HomeHeader.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/17/25.
//

import SwiftUI

struct HomeHeader<Content: View>: View {
    
    @ViewBuilder public var content: Content
    
    var body: some View {
        content
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(
                .bar
            )
    }
}


#Preview {
    HomeHeader {
        HStack {
            Text("Title")
            Spacer()
            Image(systemName: "plus")
        }
    }
}
