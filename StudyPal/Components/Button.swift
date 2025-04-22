//
//  Button.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/17/25.
//

/*
 Buttons will be used everywhere in our app so it is a good idea to make this generic UI functionality available all over the project
 */

import SwiftUI

struct Button<Content: View>: View {
    
    @State private var isPressed: Bool = false
    private var content: Content
    private var action: () -> Void
    
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
        self.isPressed = false
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            self.content
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.primary, lineWidth: 1)
            ,alignment: .center
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    withAnimation(.easeInOut) {
                        self.isPressed = true
                    }
                }
                .onEnded { value in
                    withAnimation(.easeInOut) {
                        self.isPressed = false
                    }
                    
                    self.action()
                }
        )
//        .onTapGesture {
//            withAnimation(.easeInOut, completionCriteria: .logicallyComplete, {
//                self.action()
//                isPressed = true
//            }, completion: {
//                withAnimation {
//                    isPressed = false
//                }
//            })
//        }
    }
}

#Preview {
    Button(action: { print("hi") }) {
        Text("This is my button text")
            .padding()
    }
}
