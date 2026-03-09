//
//  BudgetView.swift
//  TravelTrip
//
//  Transparent Budget Snapshot — True Cost including
//  rideshare, meals, tips to prevent budget dropouts
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct BudgetView: View {
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
                    budgetContent
                } else {
                    ContentUnavailableView(
                        "No trip selected",
                        systemImage: "airplane",
                        description: Text("Create or join a trip first.")
                    )
                }
            }
            .background(groupedBackgroundColor)
            .navigationTitle("Budget")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Item") { showAddSheet = true }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddBudgetItemSheet(onAdd: { showAddSheet = false })
                    .environmentObject(authManager)
                    .environmentObject(tripManager)
            }
        }
    }
    
    private var budgetContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                totalSnapshotCard
                breakdownSection
                Spacer(minLength: 40)
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    private var totalSnapshotCard: some View {
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
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var breakdownSection: some View {
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
                    BudgetCategoryRow(category: cat, items: tripManager.currentTripBudgetItems.filter { $0.category == cat }, secondaryBackgroundColor: secondaryBackgroundColor)
                }
            }
        }
        .padding()
        .background(secondaryBackgroundColor)
        .cornerRadius(12)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

private struct BudgetCategoryRow: View {
    let category: BudgetCategory
    let items: [BudgetItem]
    let secondaryBackgroundColor: Color
    
    private var categoryTotal: Double { items.reduce(0.0) { $0 + $1.amount } }
    
    var body: some View {
        Group {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(category.rawValue.capitalized)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text(categoryTotal, format: .currency(code: "USD"))
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
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                    }
                }
                .padding()
                .background(secondaryBackgroundColor)
                .cornerRadius(8)
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
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Item").font(.headline)
                        TextField("e.g. NYC flight", text: $name)
                            .textFieldStyle(.roundedBorder)
                        TextField("Amount (e.g. 250 or $250)", text: $amount)
                            .textFieldStyle(.roundedBorder)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        Text("Fill both name and amount to enable Add")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category").font(.headline)
                        Picker("Category", selection: $category) {
                            ForEach(BudgetCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue.capitalized).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    Toggle("Estimated (e.g. avg meal, Uber)", isOn: $isEstimated)
                }
                .padding()
            }
            .navigationTitle("Add Budget Item")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                        onAdd()
                    }
                    .disabled(name.isEmpty || parsedAmount == nil)
                }
            }
        }
    }
    
    private var parsedAmount: Double? {
        let cleaned = amount.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
        return Double(cleaned)
    }
    
    private func addItem() {
        guard let amt = parsedAmount, let tripId = tripManager.currentTripId, let userId = authManager.currentUser?.id else { return }
        tripManager.addBudgetItem(tripId: tripId, category: category, name: name, amount: amt, isEstimated: isEstimated, userId: userId)
    }
}
