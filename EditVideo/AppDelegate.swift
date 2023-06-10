//
//  AppDelegate.swift
//  EditVideo
//
//  Created by tomosia on 31/01/2023.
//

import UIKit
import PhotosUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // Permission granted, handle accordingly
                print("Photo library access authorized")

            case .denied, .restricted:
                // Permission denied or restricted, handle accordingly
                print("Photo library access denied or restricted")

            case .notDetermined:
                // User has not yet made a choice, handle accordingly
                print("Photo library access not determined")

            default:
                break
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle
}
