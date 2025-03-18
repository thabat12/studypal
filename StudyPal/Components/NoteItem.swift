//
//  NoteItem.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/17/25.
//

import SwiftUI

struct NoteItem: View {
    
    @State private var tapped = false
    
    let name: String
    let date: String
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(name)
                    .fontWeight(.semibold)
                Text(date)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .contentShape(.rect())
        .scaleEffect(tapped ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                tapped.toggle()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tapped.toggle()
                }
            }
            
        }
    }
}

#Preview {
    NoteItem(name: "Note Entry", date: "1/1/2020")
}
