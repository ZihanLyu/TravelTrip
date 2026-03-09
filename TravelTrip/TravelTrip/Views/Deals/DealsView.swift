//
//  DealsView.swift
//  TravelTrip
//
//  10-Minute Decision Notification — volatile deals
//  Approve/Reject interface for fast group consensus
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct DealsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @Binding var showAddSheet: Bool
    @State private var now = Date()
    
    private var dealsGroupedBackgroundColor: Color {
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
                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                }
                                .padding(EdgeInsets(top: 48, leading: 0, bottom: 48, trailing: 0))
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
            .background(dealsGroupedBackgroundColor)
            .navigationTitle("Deals")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Deal") { showAddSheet = true }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddDealSheet(onAdd: { showAddSheet = false })
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
        .background(dealCardBackgroundColor)
        .cornerRadius(12)
    }
    
    private var dealCardBackgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
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
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Deal").font(.headline)
                        TextField("Title (e.g. NYC flight)", text: $title)
                            .textFieldStyle(.roundedBorder)
                        TextField("Description", text: $description)
                            .textFieldStyle(.roundedBorder)
                        TextField("Price", text: $price)
                            .textFieldStyle(.roundedBorder)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Time limit").font(.headline)
                        Picker("Expires in", selection: $expiresIn) {
                            Text("5 min").tag(5)
                            Text("10 min").tag(10)
                            Text("15 min").tag(15)
                            Text("30 min").tag(30)
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
            }
            .navigationTitle("Add Deal")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
