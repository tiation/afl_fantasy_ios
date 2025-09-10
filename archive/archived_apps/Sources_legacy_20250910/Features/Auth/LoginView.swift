//
//  LoginView.swift
//
//  Simple login view for AFL Fantasy app authentication
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("AFL Fantasy AI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your intelligent fantasy companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Login form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        TextField("Enter your email", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Enter your password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal)
                
                // Login button
                Button {
                    viewModel.login()
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                .padding(.horizontal)
                
                // Alternative options
                VStack(spacing: 16) {
                    HStack {
                        VStack { Divider() }
                        Text("OR")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        VStack { Divider() }
                    }
                    
                    Button {
                        viewModel.showTeamImport = true
                    } label: {
                        Label("Import from AFL Fantasy", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.secondary.opacity(0.1))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Footer
                Text("New to AFL Fantasy AI? Create your profile by importing your existing team.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Welcome")
            .navigationBarHidden(true)
            .alert("Login Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $viewModel.showTeamImport) {
                TeamImportView()
            }
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showTeamImport = false
    
    private let keychainManager = KeychainManager()
    
    func login() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        
        // Simulate login process
        Task {
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                
                // For demo purposes, accept any credentials
                // Store user session info
                keychainManager.storeAFLUsername(email)
                
                // In real app, this would navigate to main app or set auth state
                // For now, just show success
                isLoading = false
                
            } catch {
                isLoading = false
                errorMessage = "Login failed. Please try again."
                showError = true
            }
        }
    }
    
    func checkForExistingCredentials() {
        // Check if user already has AFL credentials
        if keychainManager.hasAFLCredentials() {
            // User is already logged in, could navigate to main app
        }
    }
}

#Preview {
    LoginView()
}
