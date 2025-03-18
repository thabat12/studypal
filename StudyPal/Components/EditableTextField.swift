//
//  EditableTextField.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/17/25.
//

import SwiftUI

struct EditableTextField: View {
    
    @Binding public var textContent: String
    @State private var isEditing: Bool = false
    
    var body: some View {
        HStack {
            if isEditing {
                TextField(text: $textContent, prompt: Text("Your Name")) {
                }
                .frame(maxWidth: .infinity)
                .contentShape(.rect())
                .onSubmit {
                    isEditing = false
                }
            } else {
                HStack {
                    Text(textContent.elementsEqual("") ? "<No Name>" : textContent)
                    Spacer()
                    Image(systemName: "pencil")
                }
                .frame(maxWidth: .infinity)
                .contentShape(.rect())
                .onTapGesture {
                    isEditing = true
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    @Previewable @State var textContent = ""
    EditableTextField(textContent: $textContent)
}
