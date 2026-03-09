//
//  HomeView.swift
//  InviteApp
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello, \(authManager.currentUser?.displayName ?? "there")!")
                            .font(.title2.bold())
                        Text("You're all set. Invite friends from the Invite tab.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.3),
                                Color.accentColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Quick actions
                    VStack(spacing: 12) {
                        Button {
                            selectedTab = 1
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Invite People")
                                        .font(.headline)
                                    Text("Share your link")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject({
            let m = AuthManager()
            m.login(email: "test@example.com", displayName: "Test")
            return m
        }())
}
