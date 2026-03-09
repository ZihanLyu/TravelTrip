//
//  Deal.swift
//  TravelTrip
//
//  10-minute decision notification for volatile travel deals
//

import Foundation

struct Deal: Codable, Identifiable {
    let id: String
    var tripId: String
    var title: String
    var description: String
    var price: Double
    var expiresAt: Date
    var createdByUserId: String
    let createdAt: Date
    var approvals: [String] // userIds who approved
    var rejections: [String] // userIds who rejected
    var status: DealStatus
    
    enum DealStatus: String, Codable {
        case pending
        case approved
        case rejected
        case expired
    }
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    var timeRemaining: TimeInterval {
        max(0, expiresAt.timeIntervalSinceNow)
    }
}
