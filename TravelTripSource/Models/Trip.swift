//
//  Trip.swift
//  TravelTrip
//

import Foundation

struct Trip: Codable, Identifiable {
    let id: String
    var name: String
    var organizerId: String
    var memberIds: [String]
    var inviteCode: String
    var status: TripStatus
    let createdAt: Date
    
    enum TripStatus: String, Codable, CaseIterable {
        case planning
        case active
        case completed
    }
}
