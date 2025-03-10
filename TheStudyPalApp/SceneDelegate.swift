//
//  SceneDelegate.swift
//  TheStudyPalApp
//
//  Created by Abhi Bichal on 3/10/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // ABHINAV: to configure tab bar/ nav bar controllers we have to do things here
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // this iOS app contains only one scene, so we can just configure the tab bar controller & embed it with the root view controller here
        window = UIWindow(windowScene: windowScene)
        
        let homeScreenVC = HomeScreenViewController()
        let groupsVC = GroupsViewController()
        
        let tabBarController = UITabBarController()
        
        // both the separate view controllers must be embedded in their own navigation controllers!
        let homeNavController = UINavigationController(rootViewController: homeScreenVC)
        let groupNavController = UINavigationController(rootViewController: groupsVC)
        
        tabBarController.viewControllers = [homeNavController, groupNavController]
        
        homeScreenVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house.fill"), tag: 1
        )
        
        groupsVC.tabBarItem = UITabBarItem(
            title: "Groups",
            image: UIImage(systemName: "rectangle.3.group.bubble.fill"),
            tag: 2
        )
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

