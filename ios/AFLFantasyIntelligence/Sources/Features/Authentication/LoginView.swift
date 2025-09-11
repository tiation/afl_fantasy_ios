import SwiftUI
import LocalAuthentication

// MARK: - LoginView

struct LoginView: View {
    @StateObject private var authService = AuthenticationService()
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingPassword = false
    @State private var rememberMe = false
    
    private let demoCredentials = (email: "demo@aflapp.com", password: "password")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // App Logo and Title
                    VStack(spacing: DS.Spacing.m) {
                        Image(systemName: "sportscourt")
                            .font(.system(size: 80))
                            .foregroundColor(DS.Colors.primary)
                        
                        Text("AFL Fantasy Intelligence")
                            .font(DS.Typography.largeTitle)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Text("Your ultimate fantasy companion")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DS.Spacing.xxl)
                    
                    // Login Form
                    VStack(spacing: DS.Spacing.l) {
                        // Email Field
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text("Email")
                                .font(DS.Typography.body)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disabled(authService.isLoading)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text("Password")
                                .font(DS.Typography.body)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                            
                            HStack {
                                if showingPassword {
                                    TextField("Enter your password", text: $password)
                                        .textContentType(.password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .textContentType(.password)
                                }
                                
                                Button {
                                    showingPassword.toggle()
                                } label: {
                                    Image(systemName: showingPassword ? "eye.slash" : "eye")
                                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                                }
                            }
                            .textFieldStyle(CustomTextFieldStyle())
                            .disabled(authService.isLoading)
                        }
                        
                        // Remember Me
                        HStack {
                            Button {
                                rememberMe.toggle()
                            } label: {
                                HStack(spacing: DS.Spacing.xs) {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(rememberMe ? DS.Colors.primary : DS.Colors.onSurfaceSecondary)
                                    
                                    Text("Remember me")
                                        .font(DS.Typography.body)
                                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button("Forgot Password?") {
                                // TODO: Implement forgot password
                            }
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.primary)
                        }
                    }
                    
                    // Login Buttons
                    VStack(spacing: DS.Spacing.m) {
                        // Email Login Button
                        Button {
                            Task {
                                await authService.login(email: email, password: password)
                            }
                        } label: {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign In")
                                        .font(DS.Typography.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(DS.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                        
                        // Biometric Login Button (disabled for demo)
                        // Biometric authentication would be implemented here
                    }
                    
                    // Demo Login Helper
                    VStack(spacing: DS.Spacing.s) {
                        Divider()
                            .padding(.vertical, DS.Spacing.m)
                        
                        Text("Demo Account")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                        
                        Button("Use Demo Credentials") {
                            email = demoCredentials.email
                            password = demoCredentials.password
                        }
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.primary)
                    }
                    
                    // Sign Up Option
                    VStack(spacing: DS.Spacing.s) {
                        Text("Don't have an account?")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                        
                        Button("Create Account") {
                            // TODO: Implement sign up flow
                        }
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.primary)
                    }
                    .padding(.top, DS.Spacing.l)
                }
                .padding(DS.Spacing.l)
            }
            .navigationBarHidden(true)
            .alert("Login Error", isPresented: .constant(authService.errorMessage != nil)) {
                Button("OK") {
                    authService.errorMessage = nil
                }
            } message: {
                if let error = authService.errorMessage {
                    Text(error)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Computed Properties
    
    // Biometric authentication would be implemented here
}

// MARK: - CustomTextFieldStyle

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DS.Spacing.m)
            .background(DS.Colors.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(DS.Colors.outline, lineWidth: 1)
            )
    }
}

// MARK: - Preview

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.light)
            
            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}
#endif
