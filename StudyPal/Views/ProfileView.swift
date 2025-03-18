//
//  ProfileView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/15/25.
//

import SwiftUI

struct ProfileView: View {
    
    @State public var nameText: String = "First Last"
    
    func openCalendar() {
        print("Open calendar called")
        if let url = URL(string: "calshow://") {
            // Attempt to open the Calendar app
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // If the Calendar app is not available (unlikely), fallback to opening a URL
                print("Unable to open Calendar app.")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // MARK: Profile Pic and Name/ Affiliation
            HStack() {
                RoundedRectangle(cornerRadius: 35)
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .leading) {
                    HStack {
                        EditableTextField(textContent: $nameText)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("Affiliation")
                }
                .padding(.leading, 30)
                
                Spacer()
            }
            .frame(height: 70)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .padding(.top, 50)
            
            
            // MARK: Major/ Courses
            VStack {
                    
                // Major Section
                HStack {
                    Text("Major:")
                        .frame(width: 80, alignment: .leading)
                    Spacer()
                    Button(action: { print("major button clicked") }) {
                        Text("major...")
                            .frame(width: 200)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    Spacer()
                }
                    
                // Courses Section
                HStack {
                    Text("Courses:")
                        .frame(width: 80, alignment: .leading)
                    Spacer()
                    Button(action: {print("courses button clicked")}) {
                        Text("courses...")
                            .frame(width: 200)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    Spacer()
                }
                
                // Integration Settings
                VStack {
                    Text("Integrations:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)
                    
                    Button(action: openCalendar) {
                        Text("Apple Calendar")
                            .frame(width: 200)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                }
                .padding(.top, 50)
                
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    ProfileView()
}
