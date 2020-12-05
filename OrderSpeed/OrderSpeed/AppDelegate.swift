//
//  AppDelegate.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/3/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import UserNotifications
import FBSDKCoreKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    var user:UserBeer?
    var isConnect = false
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)], for: UIControl.State.normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.disabled)
        
        FirebaseApp.configure()
        registerNotification(application)
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("AppDelegate - \(#function) - \(#line) - deviceToken : \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("AppDelegate - \(#line) - Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("AppDelegate - \(#line) - Remote instance ID token: \(result.token)")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
              print("AppDelegate - \(#function) - \(#line) - userInfo : Message ID: \(messageID)")
            }
        print("AppDelegate - \(#function) - \(#line) - userInfo : \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("AppDelegate - \(#function) - \(#line) - Message ID: \(messageID)")
        }

        // Print full message.
        print("AppDelegate - \(#function) - \(#line) - userInfo : \(userInfo)")

        completionHandler(UIBackgroundFetchResult.newData)
      }
    
    func registerNotification(_ application: UIApplication) {
        print("AppDelegate - \(#function) - \(#line) - START")
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
    
    func connectGetLabel() {
        Firestore.firestore().collection(OrderFolderName.settings.rawValue).document("LabelCurrency").getDocument { (snapshot, error) in
            if let document = snapshot?.data() {
                if let tiGia = document["value"] as? String, let sOnVer = document["version"] as? String {
                    if let apVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        if apVer == sOnVer {
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
    
    func connectGetCurrencyRate() {
        Firestore.firestore().collection(OrderFolderName.settings.rawValue).document("CurrencyRate").getDocument { (snapshot, error) in
            if let document = snapshot?.data() {
                if let tiGia = document["value"] as? Double {
                    Tools.TI_GIA_NDT = tiGia
                }
            }
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 60) {
                self.isConnect = false
            }
        }
    }
    
    func connectGetFeeSercive() {
        Firestore.firestore().collection(OrderFolderName.settings.rawValue).document("FeeService").getDocument { (snapshot, error) in
            if let document = snapshot?.data() {
                if let tiGia = document["value"] as? Double {
                    Tools.FEE_SERVICE = tiGia
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if !isConnect {
            isConnect = true
            connectGetCurrencyRate()
            connectGetFeeSercive()
            connectGetLabel()
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        isConnect = false
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
        if url.absoluteString.hasPrefix("fb") {
            ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
        return GIDSignIn.sharedInstance().handle(url)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
          return
        }

        guard let authentication = user.authentication else { return }
        let _ = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
    }
    
    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "OrderSpeed")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Appdelegate - \(#function) - \(#line) - Message ID: \(messageID)")
        }

        // Print full message.
        print("Appdelegate - \(#function) - \(#line) - userInfo: \(userInfo)")

        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
        print("Appdelegate - \(#function) - \(#line) - Message ID: \(messageID)")
        }

        print("Appdelegate - \(#function) - \(#line) - userInfo: \(userInfo)")
        if let orderID = userInfo["order_id"] as? String {
            print("Appdelegate - \(#function) - \(#line) - orderID: \(orderID)")
//            let sb = UIStoryboard(name: "Main", bundle: nil)
//            if #available(iOS 13.0, *) {
//                let tabbar = sb.instantiateViewController(identifier: "MainTabbar") as! UITabBarController
//                window?.rootViewController = tabbar
//            } else {
//                let tabbar = sb.instantiateViewController(withIdentifier: "MainTabbar") as! UITabBarController
//                window?.rootViewController = tabbar
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_POST_ORDER_ID"), object: orderID, userInfo: nil)
            }
        }
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
  // [END refresh_token]
}
