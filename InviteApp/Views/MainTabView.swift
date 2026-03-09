//
//  MainTabView.swift
//  InviteApp
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            InviteView()
                .tabItem {
                    Label("Invite", systemImage: "person.badge.plus")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(2)
        }
        .environmentObject(authManager)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
