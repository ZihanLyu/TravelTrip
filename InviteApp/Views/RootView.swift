//
//  RootView.swift
//  InviteApp
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
    }
}
