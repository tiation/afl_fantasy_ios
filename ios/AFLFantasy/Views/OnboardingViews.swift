//
//  OnboardingViews.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - AFLTeam

enum AFLTeam: String, CaseIterable {
    case adelaide = "Adelaide Crows"
    case brisbane = "Brisbane Lions"
    case carlton = "Carlton Blues"
    case collingwood = "Collingwood Magpies"
    case essendon = "Essendon Bombers"
    case fremantle = "Fremantle Dockers"
    case geelong = "Geelong Cats"
    case goldCoast = "Gold Coast Suns"
    case gws = "GWS Giants"
    case hawthorn = "Hawthorn Hawks"
    case melbourne = "Melbourne Demons"
    case northMelbourne = "North Melbourne Kangaroos"
    case portAdelaide = "Port Adelaide Power"
    case richmond = "Richmond Tigers"
    case stKilda = "St Kilda Saints"
    case sydney = "Sydney Swans"
    case westCoast = "West Coast Eagles"
    case westernBulldogs = "Western Bulldogs"

    var emoji: String {
        switch self {
        case .adelaide: "🔴"
        case .brisbane: "🦁"
        case .carlton: "🔵"
        case .collingwood: "⚫"
        case .essendon: "🔴"
        case .fremantle: "⚓"
        case .geelong: "🐱"
        case .goldCoast: "☀️"
        case .gws: "🟠"
        case .hawthorn: "🦅"
        case .melbourne: "🔴"
        case .northMelbourne: "🦘"
        case .portAdelaide: "⚡"
        case .richmond: "🐅"
        case .stKilda: "⚪"
        case .sydney: "🔴"
        case .westCoast: "🦅"
        case .westernBulldogs: "🐶"
        }
    }

    var colors: [Color] {
        switch self {
        case .adelaide: [.red, .blue, .yellow]
        case .brisbane: [.red, .blue, .yellow]
        case .carlton: [.blue, .white]
        case .collingwood: [.black, .white]
        case .essendon: [.red, .black]
        case .fremantle: [.purple, .white]
        case .geelong: [.blue, .white]
        case .goldCoast: [.red, .yellow]
        case .gws: [.orange, .black]
        case .hawthorn: [.brown, .yellow]
        case .melbourne: [.red, .blue]
        case .northMelbourne: [.blue, .white]
        case .portAdelaide: [.teal, .black]
        case .richmond: [.yellow, .black]
        case .stKilda: [.red, .black, .white]
        case .sydney: [.red, .white]
        case .westCoast: [.blue, .yellow]
        case .westernBulldogs: [.red, .white, .blue]
        }
    }
}

// MARK: - OnboardingCoordinator

@MainActor
class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingStep = .splash
    @Published var userName: String = ""
    @Published var favoriteTeam: AFLTeam? = nil
    @Published var teamId: String = ""
    @Published var sessionCookie: String = ""
    @Published var isValidating: Bool = false
    @Published var validationError: String? = nil
    @Published var isCompleted: Bool = false

    private let keychainManager = KeychainManager()

    enum OnboardingStep {
        case splash
        case welcome
        case personalInfo
        case credentials
        case validation
        case complete
    }

    func nextStep() {
        switch currentStep {
        case .splash:
            currentStep = .welcome
        case .welcome:
            currentStep = .personalInfo
        case .personalInfo:
            currentStep = .credentials
        case .credentials:
            currentStep = .validation
            validateCredentials()
        case .validation:
            currentStep = .complete
        case .complete:
            completeOnboarding()
        }
    }

    func previousStep() {
        switch currentStep {
        case .welcome:
            currentStep = .splash
        case .personalInfo:
            currentStep = .welcome
        case .credentials:
            currentStep = .personalInfo
        case .validation:
            currentStep = .credentials
        default:
            break
        }
    }

    private func validateCredentials() {
        guard !teamId.isEmpty, !sessionCookie.isEmpty else {
            validationError = "Please fill in all credential fields"
            return
        }

        isValidating = true
        validationError = nil

        // Create validation request
        let validationData = [
            "team_id": teamId.trimmingCharacters(in: .whitespacesAndNewlines),
            "session_cookie": sessionCookie.trimmingCharacters(in: .whitespacesAndNewlines)
        ]

        Task {
            do {
                let url = URL(string: "http://127.0.0.1:9001/api/afl-fantasy/validate-credentials")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: validationData)

                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                    await MainActor.run {
                        isValidating = false

                        if httpResponse.statusCode == 200,
                           let isValid = result?["valid"] as? Bool,
                           isValid
                        {
                            // Credentials are valid, proceed to next step
                            nextStep()
                        } else {
                            // Show validation error
                            validationError = result?["error"] as? String ?? "Invalid credentials"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isValidating = false
                    validationError = "Network error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func completeOnboarding() {
        // Save all data to keychain
        keychainManager.completeUserProfile(
            name: userName,
            favoriteTeam: favoriteTeam?.rawValue ?? "Unknown",
            teamId: teamId,
            sessionCookie: sessionCookie
        )

        isCompleted = true
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @StateObject private var coordinator = OnboardingCoordinator()
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.orange, .red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Content
            Group {
                switch coordinator.currentStep {
                case .splash:
                    SplashView()
                case .welcome:
                    WelcomeView()
                case .personalInfo:
                    PersonalInfoView()
                case .credentials:
                    CredentialsView()
                case .validation:
                    ValidationView()
                case .complete:
                    CompletionView()
                }
            }
            .environmentObject(coordinator)
        }
        .onChange(of: coordinator.isCompleted) { _, completed in
            if completed {
                onComplete()
            }
        }
    }
}

// MARK: - SplashView

struct SplashView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var logoScale: CGFloat = 0.8
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App Logo/Icon
            VStack(spacing: 20) {
                Image(systemName: "football.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: logoScale)

                if showContent {
                    VStack(spacing: 12) {
                        Text("AFL Fantasy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Intelligence Platform")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }

            Spacer()

            if showContent {
                Button("Get Started") {
                    coordinator.nextStep()
                }
                .buttonStyle(OnboardingButtonStyle())
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .onAppear {
            // Start logo animation
            logoScale = 1.1

            // Show content after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.8)) {
                    showContent = true
                }
            }
        }
    }
}

// MARK: - WelcomeView

struct WelcomeView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 20) {
                Text("👋")
                    .font(.system(size: 60))

                Text("Welcome to AFL Fantasy Intelligence")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(
                    "Get personalized trade insights, captain recommendations, and real-time data to dominate your league."
                )
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 16) {
                Button("Continue") {
                    coordinator.nextStep()
                }
                .buttonStyle(OnboardingButtonStyle())

                Button("Skip Setup") {
                    // Skip to completion (will prompt for credentials later)
                    coordinator.currentStep = .complete
                }
                .foregroundColor(.white.opacity(0.8))
                .font(.body)
            }
        }
        .padding()
    }
}

// MARK: - PersonalInfoView

struct PersonalInfoView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Text("Let's personalize your experience")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Tell us a bit about yourself so we can customize the app just for you.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 24) {
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("What should we call you?")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Enter your name", text: $coordinator.userName)
                        .textFieldStyle(OnboardingTextFieldStyle())
                        .focused($isNameFieldFocused)
                }

                // Favorite Team Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Which AFL team do you support?")
                        .font(.headline)
                        .foregroundColor(.white)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(AFLTeam.allCases, id: \.self) { team in
                                TeamSelectionButton(
                                    team: team,
                                    isSelected: coordinator.favoriteTeam == team,
                                    action: {
                                        coordinator.favoriteTeam = team
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()

            // Navigation Buttons
            HStack(spacing: 16) {
                Button("Back") {
                    coordinator.previousStep()
                }
                .buttonStyle(OnboardingSecondaryButtonStyle())

                Button("Continue") {
                    coordinator.nextStep()
                }
                .buttonStyle(OnboardingButtonStyle())
                .disabled(coordinator.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .onAppear {
            isNameFieldFocused = true
        }
    }
}

// MARK: - TeamSelectionButton

struct TeamSelectionButton: View {
    let team: AFLTeam
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(team.emoji)
                    .font(.title2)

                Text(team.rawValue.replacingOccurrences(of: " ", with: "\n"))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .white.opacity(0.2) : .clear)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - CredentialsView

struct CredentialsView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var showHelp = false

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Text("🔐")
                    .font(.system(size: 50))

                Text("Connect Your AFL Fantasy Team")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("We need your AFL Fantasy details to provide personalized insights and live data.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 20) {
                // Team ID Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Team ID")
                            .font(.headline)
                            .foregroundColor(.white)

                        Button("?") {
                            showHelp.toggle()
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    }

                    TextField("e.g., 123456", text: $coordinator.teamId)
                        .textFieldStyle(OnboardingTextFieldStyle())
                        .keyboardType(.numberPad)
                }

                // Session Cookie Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Cookie")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Paste your session cookie here", text: $coordinator.sessionCookie)
                        .textFieldStyle(OnboardingTextFieldStyle())
                }
            }

            if let error = coordinator.validationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Navigation Buttons
            HStack(spacing: 16) {
                Button("Back") {
                    coordinator.previousStep()
                }
                .buttonStyle(OnboardingSecondaryButtonStyle())

                Button("Validate & Continue") {
                    coordinator.nextStep()
                }
                .buttonStyle(OnboardingButtonStyle())
                .disabled(coordinator.teamId.isEmpty || coordinator.sessionCookie.isEmpty)
            }
        }
        .padding()
        .sheet(isPresented: $showHelp) {
            CredentialHelpView()
        }
    }
}

// MARK: - ValidationView

struct ValidationView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 24) {
                if coordinator.isValidating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))

                    Text("Validating your credentials...")
                        .font(.title2)
                        .foregroundColor(.white)
                } else if let error = coordinator.validationError {
                    Text("❌")
                        .font(.system(size: 60))

                    Text("Validation Failed")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(error)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Spacer()

            if !coordinator.isValidating {
                Button("Try Again") {
                    coordinator.previousStep()
                }
                .buttonStyle(OnboardingButtonStyle())
            }
        }
        .padding()
    }
}

// MARK: - CompletionView

struct CompletionView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))

                Text("Welcome, \(coordinator.userName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    if let team = coordinator.favoriteTeam {
                        Text("Go \(team.emoji) \(team.rawValue)!")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Text("You're all set! Let's start building your championship team.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            Button("Enter AFL Fantasy Intelligence") {
                coordinator.completeOnboarding()
            }
            .buttonStyle(OnboardingButtonStyle())
        }
        .padding()
    }
}

// MARK: - CredentialHelpView

struct CredentialHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Finding Your Team ID")
                        .font(.headline)

                    Text("1. Go to fantasy.afl.com.au")
                    Text("2. Sign in to your account")
                    Text("3. Look at the URL when viewing your team")
                    Text("4. Your Team ID is the number after '/team/'")

                    Text("Example: fantasy.afl.com.au/team/123456")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Getting Your Session Cookie")
                        .font(.headline)

                    Text("1. Open Chrome/Safari Developer Tools (F12)")
                    Text("2. Go to Application/Storage tab")
                    Text("3. Click on Cookies → fantasy.afl.com.au")
                    Text("4. Find 'sessionid' and copy its value")
                }

                Text(
                    "We use these credentials securely to fetch your team data. They're stored encrypted on your device and never shared."
                )
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)

                Spacer()
            }
            .padding()
            .navigationTitle("How to Find Credentials")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

// MARK: - OnboardingButtonStyle

struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - OnboardingSecondaryButtonStyle

struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - OnboardingTextFieldStyle

struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(.white.opacity(0.1))
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview {
    OnboardingView {
        print("Onboarding completed!")
    }
}
