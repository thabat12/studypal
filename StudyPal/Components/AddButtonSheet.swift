//
//  AddButtonSheetTwo.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/21/25.
//

import SwiftUI


/*
 This is a dynamic button-sheet UI element which is controlled by:
  - parent view will determine the hitbox of whenever to close the button options, and that is passed as a binding into the button sheet
  - the button sheet will listen to the binding value changes, and will update itself accordingly
  - this code needs to be optimized sometime in the future
 */
struct AddButtonSheet<Content: View>: View {
    // Custom behavior on the button
    public var iconDim: CGFloat = 60
    public var padding: CGFloat = 10
    public var dampingFraction = 0.7
    public var pressedScalingDownRatio: CGFloat = 0.90
    
    
    // Dictates the background shape morphisms
    @State private var showIcon: Bool = true
    @State private var showMenuItems: Bool = false
    
    // Bindings allow the parent view to define a hitbox for closing the button menu
    @Binding public var expandedBinding: Bool
    @State private var expanded: Bool = false
    @State private var animationRunning = false
    
    // Used for responsiveness on interactions
    @State private var isPressed: Bool = false
    
    // Options sheet (transparent bg is preferrable)
    @ViewBuilder public var content: Content
    
    var body: some View {
        // The ZStack is the button!
        ZStack(alignment: .bottomTrailing) {
            
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconDim - 2 * padding, height: iconDim - 2 * padding)
                .padding(padding)
                .foregroundStyle(Color.white)
                .scaleEffect(isPressed ? pressedScalingDownRatio : 1.0)
                .opacity(showIcon ? 1.0 : 0.0)
            
            // This will determine the size of the ZStack!
            content
                .opacity(showMenuItems ? 1.0: 0.0)
        }
        .background(
                // background will not grow and will have a pre-determined size set already
                GeometryReader {
                    geometry in
                    
                    ZStack(alignment: .bottomTrailing) {
                        Color.clear
                        RoundedRectangle(cornerRadius: expanded ? 10 : iconDim / 2)
                            .frame(maxWidth: expanded ? geometry.size.width : iconDim, maxHeight: expanded ? geometry.size.height : iconDim)
                            .scaleEffect(isPressed ? pressedScalingDownRatio : 1.0)
                            .foregroundStyle(Color.blue)
                    }
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged {_ in
                    
                    if animationRunning { return }
                    
                    animationRunning = true
                    if showIcon {
                        withAnimation(.easeInOut) {
                            isPressed = true
                        }
                    }
                    animationRunning = false
                }
                .onEnded {_ in
                    if animationRunning { return }
                    // Hide the icon before expanding the menu
                    animationRunning = true
                    withAnimation(.linear(duration: 0.15)) {
                        showIcon = false
                        isPressed = false
                    }
                    
                    // Expand the menu with a spring-like animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.2, dampingFraction: self.dampingFraction)) {
                            expanded = true
                        }
                    }
                    
                    // Show the menu items after the expansion animation is set
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.linear(duration: 0.2)) {
                            showMenuItems = true
                        }
                        animationRunning = false
                    }
                }
        )
        .onChange(of: expandedBinding) {
            if animationRunning { return }
 
            if expanded {
                animationRunning = true
                // Hide the menu items before shrinking the menu into the button
                withAnimation(.linear(duration: 0.1)) {
                    showMenuItems = false
                }
                
                // Shrink
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expanded = false
                    }
                }
                
                // Reveal plus icon
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.linear(duration: 0.2)) {
                        showIcon = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    animationRunning = false
                }
            }
        }
    }
}

struct PreviewView: View {
    
    @State var expandedBinding: Bool = true
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            Color.clear
            AddButtonSheet(expandedBinding: $expandedBinding) {
                
                VStack(alignment: .center) {
                    Text("Create Group")
                    
                    Divider()
                    
                    Text("Join Group")
                }
                .padding()
                .frame(maxWidth: 250)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded {_ in
                    expandedBinding.toggle()
                }
        )
        
    }
}

#Preview {
    PreviewView()
}
