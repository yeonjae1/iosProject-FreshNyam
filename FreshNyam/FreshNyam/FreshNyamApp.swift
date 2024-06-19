//
//  FreshNyamApp.swift
//  FreshNyam
//
//  Created by 고연재 on 6/14/24.
//

import SwiftUI
import UserNotifications


@main
struct FreshNyamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        //알림 설정
        func checkNotificationAuthorization() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("알림 권한이 허용되었습니다.")
                        } else {
                            print("알림 권한이 거부되었습니다.")
                        }
                    }
                case .denied:
                    print("알림 권한이 거부되었습니다.")
                case .authorized, .provisional, .ephemeral:
                    print("알림 권한이 허용되었습니다.")
                @unknown default:
                    break
                }
            }
        }


        
        // 언어를 한국어로 설정
        UserDefaults.standard.set(["ko"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        return true
    }
}
