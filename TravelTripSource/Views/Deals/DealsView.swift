//
//  DealsView.swift
//  TravelTrip
//
//  10-Minute Decision Notification — volatile deals
//  Approve/Reject interface for fast group consensus
//

import SwiftUI

struct DealsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var showAddDeal = false
    @State private var now = Date()
    
    var body: some View {
        NavigationStack {
            Group {
                if let trip = tripManager.currentTrip {
                    ScrollView {
                        VStack(spacing: 24) {
                            if tripManager.currentTripActiveDeals.isEmpty && tripManager.currentTripDeals.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "bolt.circle")
                                        .font(.system(size: 50))
                                        .foregroundColor(.orange)
                                    Text("No active deals")
                                        .font(.headline)
                                    Text("Add time-sensitive flight or hotel deals. Get quick Approve/Reject from the group.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .padding(.vertical, 48)
                            } else {
                                ForEach(tripManager.currentTripDeals) { deal in
                                    DealCard(
                                        deal: deal,
                                        currentUserId: authManager.currentUser?.id ?? "",
                                        onApprove: { tripManager.approveDeal(deal.id, userId: authManager.currentUser?.id ?? "") },
                                        onReject: { tripManager.rejectDeal(deal.id, userId: authManager.currentUser?.id ?? "") }
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
            .navigationTitle("Deals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddDeal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddDeal) {
                AddDealSheet(onAdd: { showAddDeal = false })
                    .environmentObject(authManager)
                    .environmentObject(tripManager)
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in now = Date() }
        }
    }
}

struct DealCard: View {
    let deal: Deal
    let currentUserId: String
    let onApprove: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deal.title)
                        .font(.headline)
                    Text(deal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(deal.price, format: .currency(code: "USD"))
                    .font(.headline)
            }
            
            if deal.isExpired || deal.status != .pending {
                Text(deal.status == .approved ? "Approved" : deal.status == .rejected ? "Rejected" : "Expired")
                    .font(.caption.weight(.medium))
                    .foregroundColor(deal.status == .approved ? .green : .red)
            } else {
                HStack {
                    Text(timeRemainingString)
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button {
                            onApprove()
                        } label: {
                            Label("Approve", systemImage: "checkmark.circle.fill")
                                .font(.subheadline.weight(.medium))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        Button {
                            onReject()
                        } label: {
                            Label("Reject", systemImage: "xmark.circle.fill")
                                .font(.subheadline.weight(.medium))
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var timeRemainingString: String {
        let remaining = deal.timeRemaining
        let mins = Int(remaining / 60)
        let secs = Int(remaining.truncatingRemainder(dividingBy: 60))
        return "\(mins)m \(secs)s left"
    }
}

struct AddDealSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var expiresIn = 10
    
    var onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Deal") {
                    TextField("Title (e.g. NYC flight)", text: $title)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                Section("Time limit") {
                    Picker("Expires in", selection: $expiresIn) {
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                        Text("30 min").tag(30)
                    }
                }
            }
            .navigationTitle("Add Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addDeal()
                        onAdd()
                    }
                    .disabled(title.isEmpty || Double(price) == nil)
                }
            }
        }
    }
    
    private func addDeal() {
        guard let p = Double(price), let tripId = tripManager.currentTripId, let userId = authManager.currentUser?.id else { return }
        tripManager.addDeal(tripId: tripId, title: title, description: description, price: p, expiresInMinutes: expiresIn, userId: userId)
    }
}
