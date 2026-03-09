//
//  DiscoveryView.swift
//  TravelTrip
//
//  Centralized Discovery Feed: drop TikTok, Instagram, Google Maps links
//  Parsed into shared Interest List — no context switching
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct DiscoveryView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @Binding var showAddSheet: Bool
    
    private var secondaryBackgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    private var groupedBackgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if tripManager.currentTrip != nil {
                    discoveryContent
                } else {
                    ContentUnavailableView(
                        "No trip selected",
                        systemImage: "airplane",
                        description: Text("Create or join a trip first.")
                    )
                }
            }
            .background(groupedBackgroundColor)
            .navigationTitle(tripManager.currentTrip?.name ?? "Discovery")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Link") { showAddSheet = true }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddLinkSheet(onAdd: { showAddSheet = false }, onCancel: { showAddSheet = false })
                    .environmentObject(authManager)
                    .environmentObject(tripManager)
            }
        }
    }
    
    private var discoveryContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                addLinkCard
                interestListSection
                Spacer(minLength: 40)
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    private var addLinkCard: some View {
        VStack(spacing: 12) {
            Text("Add to Interest List")
                .font(.headline)
            Text("Paste TikTok, Instagram Reels, or Google Maps links")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(secondaryBackgroundColor)
        .cornerRadius(12)
                            .onTapGesture { showAddSheet = true }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var interestListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interest List")
                .font(.headline)
            Text("\(tripManager.currentTripInterests.count) items")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if tripManager.currentTripInterests.isEmpty {
                Text("No items yet. Add links from TikTok, Instagram, or Maps.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(32)
            } else {
                ForEach(tripManager.currentTripInterests) { interest in
                    InterestRow(interest: interest) {
                        tripManager.removeInterest(interest.id)
                    }
                }
            }
        }
        .padding()
        .background(secondaryBackgroundColor)
        .cornerRadius(12)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

struct InterestRow: View {
    let interest: Interest
    let onRemove: () -> Void
    
    fileprivate static var tertiaryBackgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconForSource(interest.source))
                .font(.title2)
                .foregroundColor(colorForSource(interest.source))
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(interest.title)
                    .font(.subheadline.weight(.medium))
                Text(interest.rawUrl)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Link(destination: URL(string: interest.rawUrl) ?? URL(string: "https://")!) {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
            }
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(InterestRow.tertiaryBackgroundColor)
        .cornerRadius(8)
    }
    
    private func iconForSource(_ source: InterestSource) -> String {
        switch source {
        case .tiktok: return "music.note"
        case .instagram: return "camera.fill"
        case .googleMaps: return "map.fill"
        case .other: return "link"
        }
    }
    
    private func colorForSource(_ source: InterestSource) -> Color {
        switch source {
        case .tiktok: return Color.pink
        case .instagram: return Color.purple
        case .googleMaps: return Color.blue
        case .other: return Color.gray
        }
    }
}

struct AddLinkSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var linkInput = ""
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Paste link (TikTok, Instagram, Maps)", text: $linkInput)
                    .textFieldStyle(.roundedBorder)
                    #if os(iOS)
                    .textContentType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                    .padding()
                
                Text("Supports: tiktok.com, instagram.com/reel, google.com/maps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Link")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addLink()
                        onAdd()
                    }
                    .disabled(linkInput.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addLink() {
        let url = linkInput.trimmingCharacters(in: CharacterSet.whitespaces)
        guard !url.isEmpty, let tripId = tripManager.currentTripId, let userId = authManager.currentUser?.id else { return }
        tripManager.addInterest(url: url, tripId: tripId, userId: userId)
    }
}
