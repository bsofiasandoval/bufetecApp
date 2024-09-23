//
//  FirebAuth.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 9/22/24.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase

struct FireBaseAuth {
    static let shared = FireBaseAuth()
    
    private init() {}
    
    func signinWithGoogle(presenting: UIViewController,
                          completion: @escaping (Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error = error {
                completion(error)
                return
            }

            guard
              let user = result?.user,
              let idToken = user.idToken?.tokenString
            else {
              return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(error)
                    return
                }
                UserDefaults.standard.set(true, forKey: "signIn")
                print("SIGN IN")
            }
        }

    }
}
