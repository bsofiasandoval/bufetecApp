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
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
