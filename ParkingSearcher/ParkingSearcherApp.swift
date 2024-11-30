//
//  ParkingFinderApp.swift
//  FindP
//
//  Created by STDC_13 on 30/11/2024.
//


import SwiftUI

@main
struct ParkingFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}

