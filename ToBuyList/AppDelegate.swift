//
//  AppDelegate.swift
//  ToBuyList
//
//  Created by administrator on 12/01/2022.
//


import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
      
    Database.database().isPersistenceEnabled = true
    return true
  }
}

