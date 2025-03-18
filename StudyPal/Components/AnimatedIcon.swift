//
//  AnimatedIcon.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/15/25.
//

import SwiftUI

struct AnimatedIcon: View {
    
    @State private var isActive = false
    
    let name: String
    let sfSymbolIconName: String
    var dim: CGFloat = 35
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: sfSymbolIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: dim, height: dim)
                .symbolEffect(.bounce.down.byLayer, options: .nonRepeating, isActive: isActive)
            Text(name)
        }
        .onTapGesture {
            isActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isActive = false
            }
        }
    }
}

#Preview {
    AnimatedIcon(name: "Profile", sfSymbolIconName: "person.crop.circle.fill")
}
