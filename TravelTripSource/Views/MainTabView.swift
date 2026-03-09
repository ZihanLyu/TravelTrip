//
//  MainTabView.swift
//  TravelTrip
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoveryView()
                .tabItem { Label("Discovery", systemImage: "square.stack.3d.up.fill") }
                .tag(0)
            
            PollView()
                .tabItem { Label("Polls", systemImage: "chart.bar.fill") }
                .tag(1)
            
            BudgetView()
                .tabItem { Label("Budget", systemImage: "dollarsign.circle.fill") }
                .tag(2)
            
            DealsView()
                .tabItem { Label("Deals", systemImage: "bolt.fill") }
                .tag(3)
            
            InviteView()
                .tabItem { Label("Invite", systemImage: "person.badge.plus") }
                .tag(4)
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle.fill") }
                .tag(5)
        }
        .environmentObject(authManager)
        .environmentObject(tripManager)
    }
}
