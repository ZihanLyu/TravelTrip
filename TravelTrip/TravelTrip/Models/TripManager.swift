//
//  TripManager.swift
//  TravelTrip
//

import Foundation
import SwiftUI

final class TripManager: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var interests: [Interest] = []
    @Published var polls: [Poll] = []
    @Published var budgetItems: [BudgetItem] = []
    @Published var deals: [Deal] = []
    @Published var currentTripId: String?
    
    private let prefix = "travelTrip_"
    
    var currentTrip: Trip? {
        guard let id = currentTripId else { return nil }
        return trips.first { $0.id == id }
    }
    
    var currentTripInterests: [Interest] {
        interests.filter { $0.tripId == currentTripId }
    }
    
    var currentTripPolls: [Poll] {
        polls.filter { $0.tripId == currentTripId }
    }
    
    var currentTripBudgetItems: [BudgetItem] {
        budgetItems.filter { $0.tripId == currentTripId }
    }
    
    var currentTripDeals: [Deal] {
        deals.filter { $0.tripId == currentTripId }
    }
    
    var currentTripActiveDeals: [Deal] {
        currentTripDeals.filter { !$0.isExpired && $0.status == .pending }
    }
    
    init() {
        loadAll()
    }
    
    // MARK: - Trips
    
    func createTrip(name: String, organizerId: String) -> Trip {
        let trip = Trip(
            id: UUID().uuidString,
            name: name,
            organizerId: organizerId,
            memberIds: [organizerId],
            inviteCode: generateCode(),
            status: .planning,
            createdAt: Date()
        )
        trips.append(trip)
        currentTripId = trip.id
        saveAll()
        return trip
    }
    
    func joinTrip(inviteCode: String, userId: String) -> Trip? {
        let code = inviteCode.trimmingCharacters(in: .whitespaces).uppercased()
        guard !code.isEmpty else { return nil }
        
        if let trip = trips.first(where: { $0.inviteCode.uppercased() == code }) {
            guard !trip.memberIds.contains(userId) else {
                currentTripId = trip.id
                saveAll()
                return trip
            }
            var updated = trip
            updated.memberIds.append(userId)
            if let idx = trips.firstIndex(where: { $0.id == trip.id }) {
                trips[idx] = updated
            }
            currentTripId = trip.id
            saveAll()
            return updated
        }
        // Prototype: no backend — create local trip so joiner can explore the app
        let newTrip = Trip(
            id: UUID().uuidString,
            name: "Trip \(code)",
            organizerId: userId,
            memberIds: [userId],
            inviteCode: code,
            status: .planning,
            createdAt: Date()
        )
        trips.append(newTrip)
        currentTripId = newTrip.id
        saveAll()
        return newTrip
    }
    
    func selectTrip(_ tripId: String) {
        currentTripId = tripId
        UserDefaults.standard.set(tripId, forKey: prefix + "currentTripId")
    }
    
    // MARK: - Discovery Feed / Interests
    
    func addInterest(url: String, tripId: String, userId: String) {
        let source = Interest.parseSource(from: url)
        let title = extractTitle(from: url, source: source)
        let interest = Interest(
            id: UUID().uuidString,
            tripId: tripId,
            rawUrl: url,
            source: source,
            title: title,
            addedByUserId: userId,
            addedAt: Date()
        )
        interests.append(interest)
        saveAll()
    }
    
    private func extractTitle(from url: String, source: InterestSource) -> String {
        switch source {
        case .tiktok: return "TikTok video"
        case .instagram: return "Instagram Reel"
        case .googleMaps: return "Google Maps location"
        case .other: return url.count > 50 ? String(url.prefix(47)) + "..." : url
        }
    }
    
    func removeInterest(_ id: String) {
        interests.removeAll { $0.id == id }
        saveAll()
    }
    
    // MARK: - Polls
    
    func createPoll(tripId: String, question: String, options: [String], isAnonymous: Bool, userId: String) {
        let pollOptions = options.map { PollOption(id: UUID().uuidString, text: $0) }
        let poll = Poll(
            id: UUID().uuidString,
            tripId: tripId,
            question: question,
            options: pollOptions,
            votes: [:],
            createdByUserId: userId,
            createdAt: Date(),
            isAnonymous: isAnonymous
        )
        polls.append(poll)
        saveAll()
    }
    
    func vote(_ pollId: String, optionId: String, userId: String, anonymous: Bool) {
        guard let idx = polls.firstIndex(where: { $0.id == pollId }) else { return }
        var poll = polls[idx]
        let current = poll.votes[optionId] ?? 0
        poll.votes[optionId] = current + 1
        polls[idx] = poll
        saveAll()
    }
    
    private func generateCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }
    
    // MARK: - Budget
    
    func addBudgetItem(tripId: String, category: BudgetCategory, name: String, amount: Double, isEstimated: Bool, userId: String) {
        let item = BudgetItem(
            id: UUID().uuidString,
            tripId: tripId,
            category: category,
            name: name,
            amount: amount,
            isEstimated: isEstimated,
            addedByUserId: userId,
            addedAt: Date()
        )
        budgetItems.append(item)
        saveAll()
    }
    
    func removeBudgetItem(_ id: String) {
        budgetItems.removeAll { $0.id == id }
        saveAll()
    }
    
    var totalBudget: Double {
        currentTripBudgetItems.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Deals
    
    func addDeal(tripId: String, title: String, description: String, price: Double, expiresInMinutes: Int, userId: String) {
        let deal = Deal(
            id: UUID().uuidString,
            tripId: tripId,
            title: title,
            description: description,
            price: price,
            expiresAt: Date().addingTimeInterval(TimeInterval(expiresInMinutes * 60)),
            createdByUserId: userId,
            createdAt: Date(),
            approvals: [],
            rejections: [],
            status: .pending
        )
        deals.append(deal)
        saveAll()
    }
    
    func approveDeal(_ dealId: String, userId: String) {
        guard let idx = deals.firstIndex(where: { $0.id == dealId }) else { return }
        var deal = deals[idx]
        guard !deal.isExpired else { return }
        deal.approvals.append(userId)
        deal.rejections.removeAll { $0 == userId }
        if deal.approvals.count >= deal.rejections.count + 1 {
            deal.status = .approved
        }
        deals[idx] = deal
        saveAll()
    }
    
    func rejectDeal(_ dealId: String, userId: String) {
        guard let idx = deals.firstIndex(where: { $0.id == dealId }) else { return }
        var deal = deals[idx]
        guard !deal.isExpired else { return }
        deal.rejections.append(userId)
        deal.approvals.removeAll { $0 == userId }
        if deal.rejections.count > deal.approvals.count {
            deal.status = .rejected
        }
        deals[idx] = deal
        saveAll()
    }
    
    func markDealExpired(_ dealId: String) {
        guard let idx = deals.firstIndex(where: { $0.id == dealId }) else { return }
        var deal = deals[idx]
        if deal.isExpired { deal.status = .expired }
        deals[idx] = deal
        saveAll()
    }
    
    // MARK: - Persistence
    
    private func loadAll() {
        trips = (try? load(key: prefix + "trips")) ?? []
        interests = (try? load(key: prefix + "interests")) ?? []
        polls = (try? load(key: prefix + "polls")) ?? []
        budgetItems = (try? load(key: prefix + "budgetItems")) ?? []
        deals = (try? load(key: prefix + "deals")) ?? []
        currentTripId = UserDefaults.standard.string(forKey: prefix + "currentTripId")
        if currentTripId == nil, let first = trips.first {
            currentTripId = first.id
            UserDefaults.standard.set(first.id, forKey: prefix + "currentTripId")
        }
    }
    
    private func saveAll() {
        try? save(trips, key: prefix + "trips")
        try? save(interests, key: prefix + "interests")
        try? save(polls, key: prefix + "polls")
        try? save(budgetItems, key: prefix + "budgetItems")
        try? save(deals, key: prefix + "deals")
    }
    
    private func load<T: Decodable>(key: String) throws -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            throw NSError(domain: "TravelTrip", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func save<T: Encodable>(_ value: T, key: String) throws {
        let data = try JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }
}
