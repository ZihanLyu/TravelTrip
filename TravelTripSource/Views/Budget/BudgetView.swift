//
//  BudgetView.swift
//  TravelTrip
//
//  Transparent Budget Snapshot — True Cost including
//  rideshare, meals, tips to prevent budget dropouts
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var showAddItem = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let trip = tripManager.currentTrip {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Total snapshot
                            VStack(spacing: 8) {
                                Text("Total Trip Cost")
                                    .font(.headline)
                                Text(tripManager.totalBudget, format: .currency(code: "USD"))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                Text("Includes estimated rides, meals & tips")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(
                                LinearGradient(
                                    colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            
                            // By category
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Breakdown")
                                    .font(.headline)
                                
                                if tripManager.currentTripBudgetItems.isEmpty {
                                    Text("No items yet. Add flights, hotels, Uber estimates, meals, tips.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(24)
                                } else {
                                    ForEach(BudgetCategory.allCases, id: \.self) { cat in
                                        let items = tripManager.currentTripBudgetItems.filter { $0.category == cat }
                                        if !items.isEmpty {
                                            let total = items.reduce(0.0) { $0 + $1.amount }
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Text(cat.rawValue.capitalized)
                                                        .font(.subheadline.weight(.medium))
                                                    Spacer()
                                                    Text(total, format: .currency(code: "USD"))
                                                        .font(.subheadline.weight(.medium))
                                                }
                                                ForEach(items) { item in
                                                    HStack {
                                                        Text(item.name)
                                                            .font(.caption)
                                                        if item.isEstimated {
                                                            Text("est.")
                                                                .font(.caption2)
                                                                .foregroundColor(.orange)
                                                        }
                                                        Spacer()
                                                        Text(item.amount, format: .currency(code: "USD"))
                                                            .font(.caption)
                                                    }
                                                    .padding(.leading, 8)
                                                }
                                            }
                                            .padding()
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(8)
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
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddBudgetItemSheet(onAdd: { showAddItem = false })
                    .environmentObject(authManager)
                    .environmentObject(tripManager)
            }
        }
    }
}

struct AddBudgetItemSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var amount = ""
    @State private var category: BudgetCategory = .flights
    @State private var isEstimated = false
    
    var onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(BudgetCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue.capitalized).tag(cat)
                        }
                    }
                }
                Section {
                    Toggle("Estimated (e.g. avg meal, Uber)", isOn: $isEstimated)
                }
            }
            .navigationTitle("Add Budget Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                        onAdd()
                    }
                    .disabled(name.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func addItem() {
        guard let amt = Double(amount), let tripId = tripManager.currentTripId, let userId = authManager.currentUser?.id else { return }
        tripManager.addBudgetItem(tripId: tripId, category: category, name: name, amount: amt, isEstimated: isEstimated, userId: userId)
    }
}
