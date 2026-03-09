//
//  LoginView.swift
//  InviteApp
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, displayName
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo / Title
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Welcome")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("First time? You'll be registered automatically.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)
                
                // Form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                    
                    TextField("Display Name", text: $displayName)
                        .textFieldStyle(.plain)
                        .textContentType(.name)
                        .focused($focusedField, equals: .displayName)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                    
                    Button {
                        signIn()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Continue")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 500)
        #endif
    }
    
    private func signIn() {
        focusedField = nil
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            authManager.login(email: email, displayName: displayName)
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
