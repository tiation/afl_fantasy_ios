import SwiftUI

@available(iOS 16.0, *)
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sportscourt")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("AFL Fantasy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to access your fantasy team")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text(viewModel.isLoading ? "Signing In..." : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading || !viewModel.isFormValid)
                    
                    if viewModel.showError {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer
                VStack(spacing: 12) {
                    Text("Don't have an AFL Fantasy account?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Create Account on AFL Fantasy") {
                        if let url = URL(string: "https://fantasy.afl.com.au") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(viewModel.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                appState.login()
            }
        }
        .alert("Login Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

@available(iOS 16.0, *)
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let keychainManager = KeychainManager.shared
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail(email)
    }
    
    init() {
        // Check if we already have stored credentials
        checkStoredCredentials()
    }
    
    func login() {
        guard isFormValid else { return }
        
        isLoading = true
        showError = false
        
        // Simulate login process (in real app, this would make network request)
        Task {
            defer { isLoading = false }
            
            do {
                // Store credentials in keychain
                keychainManager.storeAFLCredentials(username: email, password: password)
                
                // In a real app, you'd validate credentials with the server here
                await MainActor.run {
                    self.isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to store credentials: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func checkStoredCredentials() {
        if let credentials = keychainManager.retrieveAFLCredentials() {
            email = credentials.username
            // Don't prefill password for security
            // Auto-authenticate if credentials exist
            isAuthenticated = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
