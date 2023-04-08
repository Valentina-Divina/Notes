//
//  AppDelegate.swift
//  CFT-Notes
//
//  Created by Valentina Divina on 05.04.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        
        let navController = UINavigationController(rootViewController: HomeViewController())
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

