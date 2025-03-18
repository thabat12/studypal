//
//  TabBar.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

import SwiftUI

/*
  //MARK: Animated TabBar for StudyPal
 */
struct AnimatedTabBar: View {
    
    /*
     // MARK: activeTab & allTabs
     @State allTabs
        The tab bar needs to keep track of all the animation states for the bar items, and create bindings for it.
        
        Because allTabs is a state variable, you may create a bidirectional binding for it via $allTabs, and then within the ForEach context you can reference it as $uiTabModel. Then in the context of the closure you may directly reference and change its values. As soon as that value changes, because it are using the @State property, the UI will trigger a re-render.
     */
    @Binding var activeTab: TabItem
    @State private var allTabs: [UITabModel] = TabItem.allCases.compactMap {
        (tabEnum: TabItem) -> UITabModel in
        UITabModel(tabItem: tabEnum, isAnimating: false)
    }
    
    // MARK: Body
    var body: some View {
        HStack(alignment: .center) {
            ForEach($allTabs) {
                $uiTabModel in
                
                VStack {
                    Image(systemName: uiTabModel.tabItem.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .symbolEffect(.bounce.down.byLayer, options: .nonRepeating, isActive: uiTabModel.isAnimating)
                    
                    Text(uiTabModel.tabItem.title)
                        .font(.caption)
                }
                .foregroundStyle(uiTabModel.tabItem == activeTab ? Color.primary : Color.gray.opacity(0.5))
                .containerShape(.rect())
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.bouncy, completionCriteria: .logicallyComplete, {
                        
                        activeTab = uiTabModel.tabItem
                        uiTabModel.isAnimating = true
                    }, completion: {
                        uiTabModel.isAnimating = false
                    })
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .padding(.top, 15)
        .background(.ultraThinMaterial)
    }
}

// MARK: Preview
#Preview {
    @Previewable @State var previewActiveTab: TabItem = .home
    return AnimatedTabBar(activeTab: $previewActiveTab)
}



