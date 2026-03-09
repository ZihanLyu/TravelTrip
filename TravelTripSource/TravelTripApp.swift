//
//  TravelTripApp.swift
//  TravelTrip - Team 8
//
//  Group trip planner for organizers and ridealong travelers.
//  Supports macOS and iOS.
//

import SwiftUI

@main
struct TravelTripApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var tripManager = TripManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(tripManager)
        }
    }
}
