//
//  AppDelegate.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 3/4/19.
//  Copyright © 2019 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FBSDKCoreKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var handle: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
         handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if user != nil {
                
                let db = Firestore.firestore()
                let uid = Auth.auth().currentUser?.uid
                db.collection("users").document(uid!).getDocument {(document, err) in
                    if !document!.exists {
                        db.collection("users").document(uid!).setData([
                            "Facebook": "",
                            "Instagram": "",
                            "Linkedin": "",
                            "Phone Number": "",
                            "Snapchat": "",
                            "Twitter": "",
                            "Venmo": ""
                        ]) {err in
                            if let err = err {
                                //error checking
                                print("ERROR: ", err.localizedDescription)
                            }
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.photoURL = nil
                            changeRequest?.commitChanges { (error) in
                                if let err = error {
                                    //error occured
                                    print(err.localizedDescription)
                                    return
                                } else {
                                    print("Deleted OG photo URL")
                                }
                            }
                            
                        }
                    }
                    if self.window?.rootViewController is LoginViewController {
                        let controller = storyboard.instantiateViewController(withIdentifier: "NavViewController")
                        self.window?.rootViewController = controller
                        self.window?.makeKeyAndVisible()
                    }
                    
                }
                        
            } else {
                    let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    self.window?.rootViewController = controller
                    self.window?.makeKeyAndVisible()
                }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AppEvents.activateApp()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKCoreKit.ApplicationDelegate.shared.application(app, open: url, options: options)
        return handled
    }
    
    


}

