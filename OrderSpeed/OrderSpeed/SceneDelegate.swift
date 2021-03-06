//
//  SceneDelegate.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/3/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var isConnect = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
//        window = UIWindow(windowScene: scene)
//        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
//        window?.rootViewController = vc
//        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func connectGetFeeSercive() {
        print("============> START")
        Firestore.firestore().collection(OrderFolderName.settings.rawValue).document("FeeService").getDocument { (snapshot, error) in
            if let document = snapshot?.data() {
                if let tiGia = document["value"] as? Double {
                    print("============> tiGia : \(tiGia)")
                    Tools.FEE_SERVICE = tiGia
                }
            }
        }
    }
    
    func connectGetCurrencyRate() {
        print("SceneDelegate - \(#function) - \(#line) - START")
        Firestore.firestore().collection(OrderFolderName.settings.rawValue).document("CurrencyRate").getDocument { [weak self](snapshot, error) in
            if let document = snapshot?.data() {
                if let tiGia = document["value"] as? Double {
                    Tools.TI_GIA_NDT = tiGia
                }
            }
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 60) {
                self?.isConnect = false
            }
        }
    }
    
    func connectGetLabel() {
        Firestore.firestore().collection(OrderFolderName.settings.rawValue).document("LabelCurrency").getDocument { (snapshot, error) in
            if let document = snapshot?.data() {
                if let tiGia = document["value"] as? String, let sOnVer = document["version"] as? String, let dOnVer = Double(sOnVer) {
                    if let apVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let dApVer = Double(apVer) {
                        if dApVer <= dOnVer {
                            Tools.NDT_LABEL = tiGia
                        } else {
                            Tools.NDT_LABEL = ""
                        }
                    } else {
                        Tools.NDT_LABEL = tiGia
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_NDT_LABEL"), object: nil, userInfo: nil)
                }
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if !isConnect {
            isConnect = true
            connectGetCurrencyRate()
            connectGetFeeSercive()
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
        isConnect = false
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        ApplicationDelegate.shared.application( UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation] )
    }

}

