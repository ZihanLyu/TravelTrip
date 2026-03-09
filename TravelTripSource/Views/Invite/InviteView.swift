//
//  InviteView.swift
//  TravelTrip
//
//  Invite people to the trip — copy/share links
//

import SwiftUI

struct InviteView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tripManager: TripManager
    @State private var showCopiedToast = false
    @State private var showShareSheet = false
    
    private var inviteLink: String {
        guard let trip = tripManager.currentTrip else { return "" }
        return "https://traveltrip.app/join/\(trip.inviteCode)"
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let trip = tripManager.currentTrip {
                    ScrollView {
                        VStack(spacing: 28) {
                            VStack(spacing: 12) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 56))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text("Invite to \(trip.name)")
                                    .font(.title2.bold())
                                Text("Share your link — copy or share to any platform.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 24)
                            
                            VStack(spacing: 16) {
                                Text("Invite Code")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.secondary)
                                Text(trip.inviteCode)
                                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                                    .tracking(4)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                Text("Invite Link")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.secondary)
                                Text(inviteLink)
                                    .font(.system(.body, design: .monospaced))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                
                                HStack(spacing: 12) {
                                    Button {
                                        copyLink()
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color.accentColor)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        showShareSheet = true
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color(.systemGray5))
                                            .foregroundColor(.primary)
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                            .padding(.horizontal, 20)
                            
                            Text("Share to Messages, WhatsApp, Twitter, Email, Slack — any platform.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            
                            Spacer(minLength: 40)
                        }
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
            .navigationTitle("Invite")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [inviteLink])
            }
            .overlay(alignment: .bottom) {
                if showCopiedToast {
                    Text("Link copied")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                }
            }
            .animation(.spring(response: 0.3), value: showCopiedToast)
        }
    }
    
    private func copyLink() {
        #if os(iOS)
        UIPasteboard.general.string = inviteLink
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(inviteLink, forType: .string)
        #endif
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showCopiedToast = false }
    }
}

// MARK: - Share Sheet
struct ShareSheet: View {
    let items: [Any]
    
    var body: some View {
        #if os(iOS)
        ShareSheetUIKit(items: items)
        #elseif os(macOS)
        ShareSheetAppKit(items: items)
        #endif
    }
}

#if os(iOS)
import UIKit
struct ShareSheetUIKit: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#if os(macOS)
import AppKit
struct ShareSheetAppKit: View {
    let items: [Any]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 20) {
            Text("Share Link").font(.headline)
            Text(items.first as? String ?? "").font(.system(.body, design: .monospaced)).lineLimit(2).padding()
            HStack {
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(items.first as? String ?? "", forType: .string)
                    dismiss()
                }
                Button("Cancel") { dismiss() }
            }
        }.padding(24).frame(width: 400)
    }
}
#endif
