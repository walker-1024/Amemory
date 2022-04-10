//
//  SceneDelegate.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/16.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        let homeNav = UINavigationController(rootViewController: HomeViewController())
        homeNav.tabBarItem.title = "主页"
        homeNav.tabBarItem.image = "icon-index".localImage?.resizeImage(size: CGSize(width: 30, height: 30))

        let historyNav = UINavigationController(rootViewController: HistoryViewController())
        historyNav.tabBarItem.title = "文件"
        historyNav.tabBarItem.image = "icon-file".localImage?.resizeImage(size: CGSize(width: 30, height: 30))

        let findNav = UINavigationController(rootViewController: OfficialAccountViewController())
        findNav.tabBarItem.title = "发现"
        findNav.tabBarItem.image = "icon-find".localImage?.resizeImage(size: CGSize(width: 32, height: 32))

        let userNav = UINavigationController(rootViewController: UserViewController())
        userNav.tabBarItem.title = "我的"
        userNav.tabBarItem.image = "icon-me".localImage?.resizeImage(size: CGSize(width: 30, height: 30))

        let tab = UITabBarController()
        tab.viewControllers = [homeNav, historyNav, findNav, userNav]

        window?.rootViewController = tab

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

