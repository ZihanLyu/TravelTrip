//
//  LoginView.swift
//  TravelTrip
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    enum Field { case email, displayName }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.2),
                    Color(red: 0.12, green: 0.1, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "airplane.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("TravelTrip")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("First time? You'll be registered automatically.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
                
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        #if os(iOS)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        #endif
                        .focused($focusedField, equals: .email)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .foregroundColor(Color.white)
                    
                    TextField("Display Name", text: $displayName)
                        .textFieldStyle(.plain)
                        #if os(iOS)
                        .textContentType(.name)
                        #endif
                        .focused($focusedField, equals: .displayName)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .foregroundColor(Color.white)
                    
                    Button {
                        signIn()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            } else {
                                Text("Continue").fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                        .background(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(Color.white)
                        .cornerRadius(12)
                    }
                    .disabled(email.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty || isLoading)
                }
                .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
                
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
