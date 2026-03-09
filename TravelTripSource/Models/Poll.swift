//
//  Poll.swift
//  TravelTrip
//
//  Anonymous preference polling for dates and destinations
//

import Foundation

struct Poll: Codable, Identifiable {
    let id: String
    var tripId: String
    var question: String
    var options: [PollOption]
    var votes: [String: Int] // optionId -> count (anonymous)
    var createdByUserId: String
    let createdAt: Date
    var isAnonymous: Bool
}

struct PollOption: Codable, Identifiable {
    let id: String
    var text: String
}

struct PollVote: Codable {
    var pollId: String
    var optionId: String
    var userId: String? // nil when anonymous
}
