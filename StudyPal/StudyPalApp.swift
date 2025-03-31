//
//  StudyPalApp.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/15/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn


class AppState: ObservableObject {
    @Published var showTab = true
}
@main
struct StudyPalApp: App {
    // Application lifecycle binding
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
            // The CoreDataStack view context is now embedded into the environment
            // We probably won't use this except for convenience since you can just rely on the static shared variables directly anyways
            .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
            .environmentObject(appState)
        }
    }
}

/*
 RootView: The TabController embedded view that acts as the root view for the entire app.
 */
struct RootView: View {
    
    @State var userLoggedIn: Bool = false
    
    var body: some View {
        ZStack {
            if userLoggedIn {
                MainView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LoginView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        // Credit: https://medium.com/@matteocuzzolin/google-sign-in-with-firebase-in-swiftui-app-c8dc7b7ed4f9
        .onAppear{
            //Firebase state change listeneer
            #if targetEnvironment(simulator)
            
            userLoggedIn = true
            
            #else
            
            Auth.auth().addStateDidChangeListener{ auth, user in
                if (user != nil) {
                    userLoggedIn = true
                } else {
                    userLoggedIn = false
                }
            }
            
            #endif
        }
    }
}

struct MainView: View {
    /*
     activeTab: This is a state variable that is passed onto the AnimatedTabBar (the animated tab bar has a reference of this state variable that is stored as a @Binding property).
     */
    @State var activeTab: TabItem = .home
    @State var drawerOffset: CGFloat = -250
    @EnvironmentObject private var appState: AppState
    @State private var showNavigationTab = true
    
    
    var body: some View {
        /*
         TabView: You may pass this `activeTab` state variable as a reference as selection for TabView, and every time that the navigation bar changes its activeTab binding reference, the TabView will dynamically set the content of the screen to that view because it is a State variable.
         */
        ZStack(alignment: .bottom) {
            TabView(selection: $activeTab) {
                NavigationStack {
                    HomeView()
                        .navigationTitle("Home")
                }
                .setupTab(.home)
                
                NavigationStack {
                    GroupsView()
                        .navigationTitle("Groups")
                }
                .setupTab(.groups)
                
                NavigationStack {
                    ProfileView()
                        .navigationTitle("Profile")
                }
                .setupTab(.profile)
            }
            
            // The $ sign allows the AnimatedTabBar to set the reference of `activeTab`, and that reference points to the @State variable that is in StudyPalApp. Every time that this reference changes, the tab will shift too.
            AnimatedTabBar(activeTab: $activeTab)
                .offset(CGSize(width: 0, height: showNavigationTab ? 0.0 : 90.0))
            
            SliderDrawer(width: 250, logoutAction: {
                Task {
                    try await logout()
                }
            })
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: drawerOffset)
        }
        .onChange(of: appState.showTab) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showNavigationTab.toggle()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    
                    if value.startLocation.x < 20 {
                        withAnimation {
                            drawerOffset = min(0, value.translation.width - 250)
                        }
                    } else {
                        withAnimation {
                            drawerOffset = min(-250, value.translation.width - 250)
                        }
                    }
                    
                }
        )
    }
    
    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}

/*
 This extension applies for any subview within TabView:
    1. ensure that the screen takes up as much width and height as possible
    2. set the tag attribute (so that the view can work with TabView)
    3. if there is a toolbar, remove it because we have a custom toolbar already defined
 */
extension View {
    @ViewBuilder
    func setupTab(_ tab: TabItem) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(tab)
            .toolbar(.hidden, for: .tabBar)
    }
}


#Preview {
    MainView()
}
