//
//  TabModel.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//
//  Credit: https://www.youtube.com/watch?v=NBPBe7MmPJ0

import Foundation

/*
 What type of tab item is this?
 */
enum TabItem: String, CaseIterable {
    case home = "house.fill"
    case groups = "rectangle.3.group.bubble.fill"
    case profile = "person.crop.circle.fill"
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .groups:
            return "Groups"
        case .profile:
            return "Profile"
        }
    }
}

/*
 For a tab bar item, it will track its state through a UITabModel
 */
struct UITabModel: Identifiable {
    let id: UUID = .init()
    let tabItem: TabItem
    var isAnimating: Bool
}
