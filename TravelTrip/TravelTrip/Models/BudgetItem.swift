//
//  BudgetItem.swift
//  TravelTrip
//
//  Transparent budget snapshot - includes invisible costs
//

import Foundation

enum BudgetCategory: String, Codable, CaseIterable {
    case flights
    case hotels
    case rideshare
    case meals
    case tips
    case activities
    case other
}

struct BudgetItem: Codable, Identifiable {
    let id: String
    var tripId: String
    var category: BudgetCategory
    var name: String
    var amount: Double
    var isEstimated: Bool // e.g. average meal, Uber estimate
    var addedByUserId: String
    let addedAt: Date
}
