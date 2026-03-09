//
//  ProfileView.swift
//  TravelTrip
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.currentUser?.displayName ?? "User")
                                .font(.title2.bold())
                            Text(authManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Current Trip") {
                    if let trip = tripManager.currentTrip {
                        LabeledContent("Trip", value: trip.name)
                        LabeledContent("Invite Code", value: trip.inviteCode)
                    } else {
                        Text("No trip selected")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("My Trips") {
                    ForEach(tripManager.trips.filter { $0.memberIds.contains(authManager.currentUser?.id ?? "") }) { trip in
                        Button {
                            tripManager.selectTrip(trip.id)
                        } label: {
                            HStack {
                                Text(trip.name)
                                if trip.id == tripManager.currentTripId {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
