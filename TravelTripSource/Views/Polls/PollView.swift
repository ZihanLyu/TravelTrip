//
//  PollView.swift
//  TravelTrip
//
//  Anonymous preference polling — rank dates and destinations
//  Hidden identity toggle for honest feedback
//

import SwiftUI

struct PollView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var showCreatePoll = false
    
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
                                        .padding(.horizontal)
                                }
                                .padding(.vertical, 48)
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
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
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
            .navigationTitle("Polls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreatePoll = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCreatePoll) {
                CreatePollSheet(onCreate: { showCreatePoll = false })
                    .environmentObject(authManager)
                    .environmentObject(tripManager)
            }
        }
    }
}

struct PollCard: View {
    let poll: Poll
    let onVote: (String) -> Void
    
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
                let votes = poll.votes[option.id] ?? 0
                let total = poll.options.reduce(0) { $0 + (poll.votes[$1.id] ?? 0) }
                let pct = total > 0 ? Double(votes) / Double(total) : 0.0
                
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
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                            .cornerRadius(2)
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: geo.size.width * pct, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CreatePollSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var optionsText = ""
    @State private var isAnonymous = true
    
    var onCreate: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField("e.g. Best date for the trip?", text: $question)
                }
                Section("Options (one per line)") {
                    TextEditor(text: $optionsText)
                        .frame(minHeight: 100)
                }
                Section {
                    Toggle("Anonymous voting", isOn: $isAnonymous)
                }
            }
            .navigationTitle("New Poll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createPoll()
                        onCreate()
                    }
                    .disabled(question.isEmpty || optionsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func createPoll() {
        let opts = optionsText.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard opts.count >= 2, let tripId = tripManager.currentTripId, let userId = authManager.currentUser?.id else { return }
        tripManager.createPoll(tripId: tripId, question: question, options: opts, isAnonymous: isAnonymous, userId: userId)
    }
}
