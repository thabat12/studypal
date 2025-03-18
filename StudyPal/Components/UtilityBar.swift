//
//  UtilityBar.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

import SwiftUI

struct UtilityBar: View {
    var body: some View {
        
        HStack(spacing: 0) {
            HStack {
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                Spacer()
            }
                .frame(maxWidth: .infinity)
            
            Text("StudyPal")
                .frame(maxWidth: .infinity)
                .font(.system(size: 20))
                .fontWeight(.semibold)
            
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: 10)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.bar)
    }
}

#Preview {
    UtilityBar()
}
