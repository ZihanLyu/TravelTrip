//
//  Interest.swift
//  TravelTrip
//
//  Parsed from TikTok, Instagram Reels, or Google Maps links
//

import Foundation

enum InterestSource: String, Codable, CaseIterable {
    case tiktok
    case instagram
    case googleMaps
    case other
}

struct Interest: Codable, Identifiable {
    let id: String
    var tripId: String
    var rawUrl: String
    var source: InterestSource
    var title: String
    var addedByUserId: String
    let addedAt: Date
    
    static func parseSource(from url: String) -> InterestSource {
        let lower = url.lowercased()
        if lower.contains("tiktok.com") || lower.contains("vm.tiktok") { return .tiktok }
        if lower.contains("instagram.com") || lower.contains("reel") { return .instagram }
        if lower.contains("google.com/maps") || lower.contains("goo.gl/maps") { return .googleMaps }
        return .other
    }
}
