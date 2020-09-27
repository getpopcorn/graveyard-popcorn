//
//  SceneDelegate.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 22/5/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Firebase
import FirebaseAuth
import PopcornKit
import PopcornTorrent
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var oldUserInterfaceStyle: UIUserInterfaceStyle!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        FirebaseApp.configure()
        
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let password = UserDefaults.standard.string(forKey: "password") ?? ""
        
        UserDefaults.standard.set(false, forKey: "isSignedIn")
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if result?.user != nil {
                    print("user signed in")
                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                } else {
                    print("no user")
                    UserDefaults.standard.set(false, forKey: "isSignedIn")
                }
            }
        }
        
        
        
        do {
            try Network.reachability = Reachability(hostname: "getpopcorn.github.io")
        } catch {
            switch error as? Network.Error {
                case let .failedToCreateWith(hostname)?:
                    print("Network error:\nFailed to create reachability object With host named:", hostname)
                case let .failedToInitializeWith(address)?:
                    print("Network error:\nFailed to initialize reachability object With address:", address)
                case .failedToSetCallout?:
                    print("Network error:\nFailed to set callout")
                case .failedToSetDispatchQueue?:
                    print("Network error:\nFailed to set DispatchQueue")
                case .none:
                    print(error)
            }
        }
        
        
        // change _ to windowScene or any name for use with the variable 'window'
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        // setup
        window = UIWindow(windowScene: windowScene)
        window?.frame = windowScene.coordinateSpace.bounds
        window?.rootViewController = MainTabBarController()
        window?.tintColor = .systemBlue
        window?.makeKeyAndVisible()
        
        
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            defaults.setValue(false, forKey: "clearCacheOnExit")
            
            defaults.setValue(8.0, forKey: "minimumSubtitleRating")
            defaults.setValue("None", forKey: "defaultLanguage")
            defaults.setValue(UIFont.boldSystemFont(ofSize: 13).familyName, forKey: "defaultFontFamily")
            defaults.setValue(13, forKey: "defaultFontSize")
            
            defaults.setValue(false, forKey: "useThreeColumns")
            defaults.setValue(false, forKey: "displayMediaTitles")
            
            
            defaults.setValue(true, forKey: "hasLaunchedBefore")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        
        if UserDefaults.standard.bool(forKey: "clearCacheOnExit") {
            do {
                let size = FileManager.default.folderSize(atPath: NSTemporaryDirectory())
                for path in try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
                    try FileManager.default.removeItem(atPath: NSTemporaryDirectory() + "/\(path)")
                }
                
                if size == 0 {
                    print("Cache was already empty, no disk space was reclaimed.".localized)
                } else {
                    print("Cleaned".localized + " \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)).")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
        if PTTorrentDownloadManager.shared().activeDownloads.count > 0 {
            for download in PTTorrentDownloadManager.shared().activeDownloads {
                download.pause()
                download.save()
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        
        if oldUserInterfaceStyle != UITraitCollection.current.userInterfaceStyle {
            
            
            
            oldUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        }
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
    }
}

