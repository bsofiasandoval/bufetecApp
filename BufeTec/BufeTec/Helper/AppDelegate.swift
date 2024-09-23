//
//  AppDelegate.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/22/24.
//

import Foundation

import UIKit
import Firebase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initializetion code for firebase
        FirebaseApp.configure()
        return true
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}
