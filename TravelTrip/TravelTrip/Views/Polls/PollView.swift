//
//  PollView.swift
//  TravelTrip
//
//  Anonymous preference polling — rank dates and destinations
//  Hidden identity toggle for honest feedback
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct PollView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @Binding var showAddSheet: Bool
    
    fileprivate static var groupedBackgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let trip = tripManager.currentTrip {
                    ScrollView {
                        VStack(spacing: 24) {
                            if tripManager.currentTripPolls.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "chart.bar.doc.horizontal")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    Text("No polls yet")
                                        .font(.headline)
                                    Text("Create a poll to vote on dates or destinations. Anonymous voting available.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                }
                                .padding(EdgeInsets(top: 48, leading: 0, bottom: 48, trailing: 0))
                            } else {
                                ForEach(tripManager.currentTripPolls) { poll in
                                    PollCard(
                                        poll: poll,
                                        onVote: { optionId in
                                            guard let userId = authManager.currentUser?.id else { return }
                                            tripManager.vote(poll.id, optionId: optionId, userId: userId, anonymous: poll.isAnonymous)
                                        }
                                    )
                                }
                            }
                            Spacer(minLength: 40)
                        }
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                    }
                } else {
                    ContentUnavailableView(
                        "No trip selected",
                        systemImage: "airplane",
                        description: Text("Create or join a trip first.")
                    )
                }
            }
            .background(PollView.groupedBackgroundColor)
            .navigationTitle("Polls")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Poll") { showAddSheet = true }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                CreatePollSheet(onCreate: { showAddSheet = false })
                    .environmentObject(authManager)
                    .environmentObject(tripManager)
            }
        }
    }
}

struct PollCard: View {
    let poll: Poll
    let onVote: (String) -> Void
    
    fileprivate static var secondaryBackgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(poll.question)
                    .font(.headline)
                if poll.isAnonymous {
                    Image(systemName: "eye.slash.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(poll.options) { option in
                PollOptionRow(
                    poll: poll,
                    option: option,
                    onVote: onVote
                )
            }
        }
        .padding()
        .background(PollCard.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}

private struct PollOptionRow: View {
    let poll: Poll
    let option: PollOption
    let onVote: (String) -> Void
    
    private var votes: Int { poll.votes[option.id] ?? 0 }
    private var total: Int { poll.options.reduce(0) { $0 + (poll.votes[$1.id] ?? 0) } }
    private var pct: Double { total > 0 ? Double(votes) / Double(total) : 0.0 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                onVote(option.id)
            } label: {
                HStack {
                    Text(option.text)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(votes) votes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(PollCard.secondaryBackgroundColor)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width * CGFloat(pct), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
    }
}

struct CreatePollSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var optionsText = "Jan 15\nFeb 20"
    @State private var isAnonymous = true
    
    var onCreate: () -> Void
    
    private var options: [String] {
        optionsText.split(separator: "\n").map { String($0).trimmingCharacters(in: CharacterSet.whitespaces) }.filter { !$0.isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Question").font(.headline)
                        TextField("e.g. Best date for the trip?", text: $question)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Options (one per line)").font(.headline)
                        TextEditor(text: $optionsText)
                            .frame(minHeight: 100)
                            .overlay(alignment: .topLeading) {
                                if optionsText.isEmpty {
                                    Text("Jan 15\nFeb 20\nMar 10")
                                        .foregroundColor(Color.secondary.opacity(0.6))
                                        .padding(8)
                                        .allowsHitTesting(false)
                                }
                            }
                        Text("One option per line (2 minimum). Edit the examples above.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Toggle("Anonymous voting", isOn: $isAnonymous)
                }
                .padding()
            }
            .navigationTitle("New Poll")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createPoll()
                        onCreate()
                    }
                    .disabled(question.isEmpty || options.count < 2)
                }
            }
        }
    }
    
    private func createPoll() {
        guard options.count >= 2, let tripId = tripManager.currentTripId, let userId = authManager.currentUser?.id else { return }
        tripManager.createPoll(tripId: tripId, question: question, options: options, isAnonymous: isAnonymous, userId: userId)
    }
}
