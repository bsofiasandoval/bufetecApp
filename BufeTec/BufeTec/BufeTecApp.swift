//
//  BufeTecApp.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/13/24.
//

// arreglar la parte de que cuando hago pruebas en flows de client login me sale view de casos al meterme desde internal login view.

import SwiftUI
import Firebase
import FirebaseAuth
import WidgetKit

@main
struct BufeTecApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authState = AuthState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .environmentObject(authState)  // Pass the global authState to HomeView
                    .onOpenURL { url in
                        handleDeepLink(url:url)
                    }
            }
        }
    }
    
    
    func handleDeepLink(url: URL) {
        if url.scheme == "myapp" {
            switch url.host {
            case "showSpeechBot":
                if authState.isLoggedIn && (authState.userRole == .abogado || authState.userRole == .becario) {
                    NotificationCenter.default.post(name: Notification.Name("showSpeechBot"), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name("showLogin"), object: nil)
                }
            case "login":
                NotificationCenter.default.post(name: Notification.Name("showLogin"), object: nil)
            default:
                break
            }
        }
    }
}



enum UserRole {
    case cliente
    case becario
    case abogado
    
}

class AuthState: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var user: User?
    @Published var userRole: UserRole?
    @AppStorage("isLoggedIn") var widgetLoggedIn: Bool = false
    
    init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser
        self.userRole = nil
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.isLoggedIn = user != nil
                self?.user = user
                self?.userRole = self?.getUserRole(user)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    private func getUserRole(_ user: User?) -> UserRole? {
        if(user == nil) {
            return nil
        }
        else if(user?.email?.hasSuffix("@tec.mx") == true || user?.email?.hasPrefix("A") == true || user?.email?.hasPrefix("a") == true){
            return .becario
        }
        else if((user?.email?.hasSuffix("@tec.mx")) == true || user?.email?.hasSuffix("@gmail") == true){
            return .abogado
        }
        else{
            return .cliente
        }
    }

    func setUserRole(_ type: UserRole) {
        DispatchQueue.main.async {
            self.userRole = type
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.widgetLoggedIn = false 
            self.user = nil
            self.userRole = nil
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}


