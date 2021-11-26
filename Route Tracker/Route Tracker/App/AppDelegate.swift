//
//  AppDelegate.swift
//  Route Tracker
//
//  Created by Lev on 11/7/21.
//

import UIKit
import GoogleMaps
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyBeaIxth9K8asqajY1LwDkcLnLV1Zinxbw")
        configureUserNotificationCenter()
        return true
    }
    
    func configureUserNotificationCenter() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                print("Permission not granted")
                return
            }
            self.sendNotificationRequest(content: self.makeNotificationContent(), trigger: self.makeIntervalNotificationTrigger())
        }
    }

    func makeNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Notification"
        content.subtitle = "Test"
        content.body = "Test"
        content.badge = 1
        return content
    }
    
    func makeIntervalNotificationTrigger() -> UNNotificationTrigger {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        return trigger
    }
    
    func sendNotificationRequest(content: UNNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
}
