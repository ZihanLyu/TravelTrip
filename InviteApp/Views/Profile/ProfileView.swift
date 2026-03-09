//
//  ProfileView.swift
//  InviteApp
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
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
                
                Section("Account") {
                    LabeledContent("Invite Code", value: authManager.currentUser?.inviteCode ?? "")
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

#Preview {
    ProfileView()
        .environmentObject({
            let m = AuthManager()
            m.login(email: "test@example.com", displayName: "Test User")
            return m
        }())
}
