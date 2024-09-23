//
//  BufeTecApp.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

import SwiftUI

@main
struct BufeTecApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("signIn") var isSignIn = false
    
    var body: some Scene {
        WindowGroup {
            if !isSignIn {
                GeneralLoginView()
            } else {
                ExploreView()
            }
        }
    }
}

