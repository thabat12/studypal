//
//  SliderDrawer.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

import SwiftUI

struct SliderDrawer: View {
    public var width: CGFloat
    public var logoutAction: () -> Void
    @State private var logoutPressed = false
    @State private var isDrawerOpen = true
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Spacer()
            
            HStack(alignment: .center) {
                Text("Logout")
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                Image(systemName: "arrow.forward.square.fill")
                    .foregroundStyle(.red)
            }
            .contentShape(.rect())
            .scaleEffect(logoutPressed ? 0.95 : 1.0)
            .onTapGesture {
                withAnimation {
                    logoutPressed = true
                    logoutAction()
                    // After some delay, you can change the state again
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        logoutPressed = false
                    }
                }
            }
        }
        .frame(maxWidth: width, maxHeight: .infinity)
        .padding(.bottom, 30)
        .background(.bar)
    }
}


#Preview {
    SliderDrawer(width: 250) {
        print("logout pressed")
    }
}
