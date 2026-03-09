//
//  CreateOrJoinTripView.swift
//  TravelTrip
//

import SwiftUI

struct CreateOrJoinTripView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var tripName = ""
    @State private var inviteCode = ""
    @State private var showJoin = false
    @State private var joinError: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Image(systemName: "airplane.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("TravelTrip")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("Create a trip or join one with an invite code")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    if !showJoin {
                        VStack(spacing: 16) {
                            TextField("Trip name", text: $tripName)
                                .textFieldStyle(.roundedBorder)
                                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                            
                            Button {
                                createTrip()
                            } label: {
                                Text("Create Trip")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(tripName.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
                            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                            
                            Button("Join an existing trip") {
                                showJoin = true
                            }
                            .foregroundColor(.secondary)
                        }
                    } else {
                        VStack(spacing: 16) {
                            TextField("Invite code", text: $inviteCode)
                                .textFieldStyle(.roundedBorder)
                                #if os(iOS)
                                .textInputAutocapitalization(.characters)
                                #endif
                                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                            
                            if let err = joinError {
                                Text(err)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            Button {
                                joinTrip()
                            } label: {
                                Text("Join Trip")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(inviteCode.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
                            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                            
                            Button("Create a new trip instead") {
                                showJoin = false
                                inviteCode = ""
                                joinError = nil
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(EdgeInsets(top: 48, leading: 0, bottom: 48, trailing: 0))
            }
        }
    }
    
    private func createTrip() {
        guard let user = authManager.currentUser else { return }
        _ = tripManager.createTrip(name: tripName.trimmingCharacters(in: CharacterSet.whitespaces), organizerId: user.id)
    }
    
    private func joinTrip() {
        guard let user = authManager.currentUser else { return }
        _ = tripManager.joinTrip(inviteCode: inviteCode.trimmingCharacters(in: CharacterSet.whitespaces), userId: user.id)
        if tripManager.currentTrip == nil {
            joinError = "Invalid or expired code"
        } else {
            joinError = nil
        }
    }
}
