//
//  AuthManager.swift
//  InviteApp
//

import Foundation
import SwiftUI

/// Manages authentication. First-time users are automatically registered.
final class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private let currentUserKey = "inviteApp_currentUser"
    private let usersKey = "inviteApp_users"
    
    init() {
        loadCurrentUser()
    }
    
    /// Login or auto-register. First-time users get an account automatically.
    func login(email: String, displayName: String) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalizedEmail.isEmpty else { return }
        
        var users = loadAllUsers()
        if let existing = users[normalizedEmail] {
            currentUser = existing
        } else {
            // Auto-register first-time user
            let newUser = User(
                id: UUID().uuidString,
                email: normalizedEmail,
                displayName: displayName.trimmingCharacters(in: .whitespaces).isEmpty ? "User" : displayName.trimmingCharacters(in: .whitespaces),
                inviteCode: generateInviteCode(),
                createdAt: Date()
            )
            users[normalizedEmail] = newUser
            saveAllUsers(users)
            currentUser = newUser
        }
        saveCurrentUser(currentUser!)
        isLoggedIn = true
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    func refreshInviteCode() {
        guard var user = currentUser else { return }
        user.inviteCode = generateInviteCode()
        var users = loadAllUsers()
        users[user.email] = user
        saveAllUsers(users)
        currentUser = user
        saveCurrentUser(user)
    }
    
    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }
    
    private func loadCurrentUser() {
        guard let email = UserDefaults.standard.string(forKey: currentUserKey),
              let user = loadAllUsers()[email] else {
            return
        }
        currentUser = user
        isLoggedIn = true
    }
    
    private func loadAllUsers() -> [String: User] {
        (try? loadAllUsersEncoded()) ?? [:]
    }
    
    private func loadAllUsersEncoded() throws -> [String: User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey) else { return [:] }
        let decoded = try JSONDecoder().decode([String: User].self, from: data)
        return decoded
    }
    
    private func saveAllUsers(_ users: [String: User]) {
        guard let data = try? JSONEncoder().encode(users) else { return }
        UserDefaults.standard.set(data, forKey: usersKey)
    }
    
    private func saveCurrentUser(_ user: User) {
        UserDefaults.standard.set(user.email, forKey: currentUserKey)
    }
}

struct User: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String
    var inviteCode: String
    let createdAt: Date
}
