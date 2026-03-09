//
//  RootView.swift
//  TravelTrip
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    
    var body: some View {
        Group {
            if !authManager.isLoggedIn {
                LoginView()
            } else if tripManager.currentTrip == nil && tripManager.trips.isEmpty {
                CreateOrJoinTripView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
        .animation(.easeInOut(duration: 0.3), value: tripManager.currentTrip?.id)
    }
}
