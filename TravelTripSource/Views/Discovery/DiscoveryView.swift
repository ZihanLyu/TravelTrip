//
//  DiscoveryView.swift
//  TravelTrip
//
//  Centralized Discovery Feed: drop TikTok, Instagram, Google Maps links
//  Parsed into shared Interest List — no context switching
//

import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var linkInput = ""
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let trip = tripManager.currentTrip {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Add link card
                            VStack(spacing: 12) {
                                Text("Add to Interest List")
                                    .font(.headline)
                                Text("Paste TikTok, Instagram Reels, or Google Maps links")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .onTapGesture { showAddSheet = true }
                            .padding(.horizontal, 20)
                            
                            // Interest List
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
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    ContentUnavailableView(
                        "No trip selected",
                        systemImage: "airplane",
                        description: Text("Create or join a trip first.")
                    )
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(tripManager.currentTrip?.name ?? "Discovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddLinkSheet(
                    linkInput: $linkInput,
                    onAdd: {
                        addLink()
                        showAddSheet = false
                        linkInput = ""
                    },
                    onCancel: {
                        showAddSheet = false
                        linkInput = ""
                    }
                )
            }
        }
    }
    
    private func addLink() {
        let url = linkInput.trimmingCharacters(in: .whitespaces)
        guard !url.isEmpty, let tripId = tripManager.currentTripId, let userId = authManager.currentUser?.id else { return }
        tripManager.addInterest(url: url, tripId: tripId, userId: userId)
    }
}

struct InterestRow: View {
    let interest: Interest
    let onRemove: () -> Void
    
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
        .background(Color(.tertiarySystemGroupedBackground))
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
        case .tiktok: return .pink
        case .instagram: return .purple
        case .googleMaps: return .blue
        case .other: return .gray
        }
    }
}

struct AddLinkSheet: View {
    @Binding var linkInput: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Paste link (TikTok, Instagram, Maps)", text: $linkInput)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                    .padding()
                
                Text("Supports: tiktok.com, instagram.com/reel, google.com/maps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onAdd() }
                        .disabled(linkInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
