//
//  AuthManager.swift
//  TravelTrip
//

import Foundation
import SwiftUI

final class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private let prefix = "travelTrip_"
    
    init() {
        loadCurrentUser()
    }
    
    func login(email: String, displayName: String) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalizedEmail.isEmpty else { return }
        
        var users = loadAllUsers()
        if let existing = users[normalizedEmail] {
            currentUser = existing
        } else {
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
        UserDefaults.standard.removeObject(forKey: prefix + "currentUser")
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
        guard let email = UserDefaults.standard.string(forKey: prefix + "currentUser"),
              let user = loadAllUsers()[email] else { return }
        currentUser = user
        isLoggedIn = true
    }
    
    private func loadAllUsers() -> [String: User] {
        (try? loadEncoded(key: prefix + "users")) ?? [:]
    }
    
    private func saveAllUsers(_ users: [String: User]) {
        try? save(users, key: prefix + "users")
    }
    
    private func saveCurrentUser(_ user: User) {
        UserDefaults.standard.set(user.email, forKey: prefix + "currentUser")
    }
    
    private func loadEncoded<T: Decodable>(key: String) throws -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else { throw NSError(domain: "", code: 0, userInfo: nil) }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func save<T: Encodable>(_ value: T, key: String) throws {
        let data = try JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }
}

struct User: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String
    var inviteCode: String
    let createdAt: Date
}
