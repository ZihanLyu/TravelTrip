//
//  InviteView.swift
//  InviteApp
//
//  Invite people with shareable links — copy or share to any platform
//

import SwiftUI

struct InviteView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showCopiedToast = false
    @State private var showShareSheet = false
    
    private var inviteLink: String {
        guard let user = authManager.currentUser else { return "" }
        // Use a shareable URL format — replace with your actual domain when deployed
        return "https://invite.app/join/\(user.inviteCode)"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Invite People")
                            .font(.title2.bold())
                        Text("Share your link to invite others. They can copy it or share it to any platform.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 24)
                    
                    // Invite code card
                    VStack(spacing: 16) {
                        Text("Your Invite Code")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        Text(authManager.currentUser?.inviteCode ?? "------")
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
                    
                    // Shareable link
                    VStack(spacing: 16) {
                        Text("Your Invite Link")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        Text(inviteLink)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .contextMenu {
                                Button {
                                    copyLink()
                                } label: {
                                    Label("Copy Link", systemImage: "doc.on.doc")
                                }
                            }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button {
                                copyLink()
                            } label: {
                                Label("Copy Link", systemImage: "doc.on.doc")
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
                        
                        Button {
                            authManager.refreshInviteCode()
                        } label: {
                            Label("Generate New Link", systemImage: "arrow.clockwise")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Share platforms hint
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Share to")
                            .font(.subheadline.weight(.semibold))
                        Text("Messages, WhatsApp, Twitter, Email, Slack — any platform. Just copy the link above or tap Share.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
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
                    Text("Link copied to clipboard")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedToast = false
        }
    }
}

// MARK: - Share Sheet (iOS & macOS)
struct ShareSheet: View {
    let items: [Any]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        #if os(iOS)
        ShareSheetUIKit(items: items)
            .ignoresSafeArea()
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
            Text("Share Link")
                .font(.headline)
            Text(items.first as? String ?? "")
                .font(.system(.body, design: .monospaced))
                .lineLimit(2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
            
            HStack {
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(items.first as? String ?? "", forType: .string)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
}
#endif

#Preview {
    InviteView()
        .environmentObject({
            let m = AuthManager()
            m.login(email: "test@example.com", displayName: "Test User")
            return m
        }())
}
