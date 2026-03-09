//
//  InviteAppApp.swift
//  InviteApp
//
//  Supports macOS and iOS
//

import SwiftUI

@main
struct InviteAppApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
        }
    }
}
