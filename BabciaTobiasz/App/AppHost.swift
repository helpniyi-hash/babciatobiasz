//
//  AppHost.swift
//  BabciaTobiasz
//
//  iOS app entry point for the Xcode app target.
//

import SwiftUI

@main
struct BabciaTobiaszApp: App {
    var body: some Scene {
        WindowGroup {
            BabciaTobiaszAppView()
                .dsTheme(.default)
        }
    }
}
