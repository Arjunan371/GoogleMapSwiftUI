//
//  GoogleMapSwiftUIApp.swift
//  GoogleMapSwiftUI
//
//  Created by Arjunan on 09/07/25.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

var apiKey = "AIzaSyAvm0wXqt0yVd6CRllfioQDo8Ec5xE3_s4"
@main
struct GoogleMapSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("App launched")
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
        return true
    }
}

// AIzaSyAvm0wXqt0yVd6CRllfioQDo8Ec5xE3_s4
