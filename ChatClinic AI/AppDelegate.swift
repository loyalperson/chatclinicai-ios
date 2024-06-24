//
//  AppDelegate.swift
//  ChatClinic AI
//
//  Created by charmer on 6/3/24.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleSignIn
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        window = UIWindow()
        FirebaseApp.configure()
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
        }
        registerForPushNotifications(application: application)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool

        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
          return true
        }

      // Handle other custom URL types.

      // If not handled by this app, return false.
        var importAlert: UIAlertController = UIAlertController(title: "Login Alert", message: "Google Login failed", preferredStyle: UIAlertController.Style.alert)
        importAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler:
        { action in
            switch action.style {
            case .default:
                break
            case .cancel:
                break
            case .destructive:
                break
            @unknown default:
                break
            }
        }))
        window?.rootViewController?.present(importAlert, animated: true, completion: nil)
        return false
    }
    func registerForPushNotifications(application: UIApplication) {
            if #available(iOS 10.0, *){
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                    if (granted)
                    {
                        DispatchQueue.main.async {
                            application.registerForRemoteNotifications()
                        }
    //                    UIApplication.shared.registerForRemoteNotifications()
                    }
                    else{
                        //Do stuff if unsuccessful...
                    }
                })
            }
            else { //If user is not on iOS 10 use the old methods we've been using
                let notificationSettings = UIUserNotificationSettings(
                    types: [.badge, .sound, .alert], categories: nil)
                application.registerUserNotificationSettings(notificationSettings)
            }
        }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession handleEventsForBackgroundURLSessionidentifier: String,
                     completionHandler: @escaping () -> Void) {
       backgroundSessionCompletionHandler = completionHandler
    }

}
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
    let userInfo = notification.request.content.userInfo
        let title = notification.request.content.title
        let body = notification.request.content.body
        let identifier = notification.request.identifier
        
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...
        
    // Print full message.
    print(userInfo)
        
    // Change this to your preferred presentation option
    return [[.alert, .sound]]
  }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription.description)
        let err:String = error.localizedDescription.description
        print (err)
    }
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.hexString
        Utils.setUserDefault(key: "device_token", value: deviceTokenString)
    }
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
    let userInfo = response.notification.request.content.userInfo
      let title = response.notification.request.content.title
      let body = response.notification.request.content.body
      let identifier = response.notification.request.identifier
      
    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
//      UIApplication.shared.applicationIconBadgeNumber += 1
    print(userInfo)
  }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
    }

}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
