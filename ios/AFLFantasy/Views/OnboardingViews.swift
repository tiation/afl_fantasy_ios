//
//  OnboardingViews.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - OnboardingError

enum OnboardingError: LocalizedError {
    case networkError(String)
    case invalidCredentials(String)
    case emptyFields
    case serverError(Int)
    case timeout
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .invalidCredentials(let message):
            return message.isEmpty ? "Invalid team credentials. Please check your Team ID and Session Cookie." : message
        case .emptyFields:
            return "Please fill in both your Team ID and Session Cookie."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .timeout:
            return "Request timed out. Please check your internet connection and try again."
        case .unknownError:
            return "Something went wrong. Please try again."
        }
    }
    
    var recoveryMessage: String {
        switch self {
        case .networkError, .timeout:
            return "Check your internet connection and try again."
        case .invalidCredentials:
            return "Double-check your credentials in the AFL Fantasy app or website."
        case .emptyFields:
            return "Make sure both fields are filled in completely."
        case .serverError:
            return "This is usually temporary. Try again in a few minutes."
        case .unknownError:
            return "If this persists, try restarting the app."
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .emptyFields:
            return false
        default:
            return true
        }
    }
}

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
    @Published var validationError: OnboardingError? = nil
    @Published var isCompleted: Bool = false
    @Published var hasExistingTeam: Bool = true // Track user choice
    @Published var showValidationAlert: Bool = false
    
    private let keychainManager = KeychainManager()
    private var validationRetryCount: Int = 0
    private let maxRetries = 3

    // Progress calculation
    var progress: Double {
        Double(currentStep.stepNumber) / Double(currentStep.totalSteps)
    }

    enum OnboardingStep: CaseIterable {
        case splash
        case welcome
        case teamChoice
        case personalInfo
        case createTeamGuide
        case credentials
        case validation
        case complete

        var stepNumber: Int {
            switch self {
            case .splash: 0
            case .welcome: 1
            case .teamChoice: 2
            case .personalInfo: 3
            case .createTeamGuide: 3 // Same as personalInfo for progress
            case .credentials: 4
            case .validation: 5
            case .complete: 6
            }
        }

        var totalSteps: Int { 6 }
    }

    func nextStep() {
        switch currentStep {
        case .splash:
            currentStep = .welcome
        case .welcome:
            currentStep = .teamChoice
        case .teamChoice:
            // Branch based on user choice
            if hasExistingTeam {
                currentStep = .personalInfo
            } else {
                currentStep = .createTeamGuide
            }
        case .personalInfo:
            currentStep = .credentials
        case .createTeamGuide:
            currentStep = .personalInfo
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
        case .teamChoice:
            currentStep = .welcome
        case .personalInfo:
            currentStep = .teamChoice
        case .createTeamGuide:
            currentStep = .teamChoice
        case .credentials:
            currentStep = .personalInfo
        case .validation:
            currentStep = .credentials
        default:
            break
        }
    }

    // New helper methods for team choice flow
    func selectHasExistingTeam() {
        hasExistingTeam = true
        nextStep()
    }

    func selectNeedsToCreateTeam() {
        hasExistingTeam = false
        nextStep()
    }

    func returnFromCreateGuide() {
        currentStep = .personalInfo
    }

    private func validateCredentials() {
        guard !teamId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !sessionCookie.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationError = .emptyFields
            showValidationAlert = true
            return
        }

        isValidating = true
        validationError = nil
        showValidationAlert = false

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
                request.timeoutInterval = 15.0 // 15 second timeout

                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    await MainActor.run {
                        isValidating = false
                        handleValidationResponse(httpResponse: httpResponse, data: data)
                    }
                } else {
                    await MainActor.run {
                        isValidating = false
                        validationError = .unknownError
                        showValidationAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isValidating = false
                    handleValidationError(error)
                }
            }
        }
    }
    
    private func handleValidationResponse(httpResponse: HTTPURLResponse, data: Data) {
        do {
            let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            switch httpResponse.statusCode {
            case 200:
                if let isValid = result?["valid"] as? Bool, isValid {
                    // Credentials are valid, reset retry count and proceed
                    validationRetryCount = 0
                    nextStep()
                } else {
                    // Invalid credentials
                    let errorMessage = result?["error"] as? String ?? ""
                    validationError = .invalidCredentials(errorMessage)
                    showValidationAlert = true
                }
            case 400:
                let errorMessage = result?["error"] as? String ?? ""
                validationError = .invalidCredentials(errorMessage)
                showValidationAlert = true
            case 429:
                validationError = .serverError(429)
                showValidationAlert = true
            case 500...599:
                validationError = .serverError(httpResponse.statusCode)
                showValidationAlert = true
            default:
                validationError = .unknownError
                showValidationAlert = true
            }
        } catch {
            validationError = .unknownError
            showValidationAlert = true
        }
    }
    
    private func handleValidationError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                validationError = .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                validationError = .networkError("No internet connection")
            case .cannotFindHost, .cannotConnectToHost:
                validationError = .networkError("Cannot reach server")
            default:
                validationError = .networkError(urlError.localizedDescription)
            }
        } else {
            validationError = .networkError(error.localizedDescription)
        }
        showValidationAlert = true
    }
    
    func retryValidation() {
        validationRetryCount += 1
        showValidationAlert = false
        validateCredentials()
    }
    
    func shouldShowSupportOption() -> Bool {
        return validationRetryCount >= maxRetries
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
                case .teamChoice:
                    TeamChoiceView()
                case .personalInfo:
                    PersonalInfoView()
                case .createTeamGuide:
                    CreateTeamGuideView()
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
    @State private var showFeaturePreview = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    private let keyBenefits = [
        "🧠 AI-powered trade recommendations",
        "⭐ Smart captain selection advice", 
        "💰 Never miss cash cow opportunities",
        "📊 Real-time performance tracking"
    ]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App Logo/Icon with reduced motion support
            VStack(spacing: 24) {
                Image(systemName: "football.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                    .animation(
                        reduceMotion ? .none : .easeInOut(duration: 2).repeatForever(autoreverses: true), 
                        value: logoScale
                    )

                if showContent {
                    VStack(spacing: 16) {
                        // Main headline
                        VStack(spacing: 8) {
                            Text("AFL Fantasy")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Intelligence Platform")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Value proposition
                        Text("Dominate your league with AI-powered insights and real-time data")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        // Key benefits list
                        VStack(spacing: 8) {
                            ForEach(keyBenefits, id: \.self) { benefit in
                                Text(benefit)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                        .padding(.top, 8)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }

            Spacer()

            if showContent {
                VStack(spacing: 16) {
                    // Primary CTA
                    Button("Let's Set Up Your Team") {
                        coordinator.nextStep()
                    }
                    .buttonStyle(OnboardingButtonStyle())
                    .accessibilityLabel("Set up your AFL Fantasy team")
                    .accessibilityHint("Start the setup process to connect your team and get personalized insights")
                    
                    // Secondary CTA
                    Button("Preview Features") {
                        showFeaturePreview = true
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .underline()
                    .accessibilityLabel("Preview app features")
                    .accessibilityHint("See what the app can do before setting up your team")
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .sheet(isPresented: $showFeaturePreview) {
            FeaturePreviewModal()
        }
        .onAppear {
            // Start logo animation (respects reduce motion)
            if !reduceMotion {
                logoScale = 1.1
            }

            // Show content after delay
            let delay = reduceMotion ? 0.3 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let duration = reduceMotion ? 0.2 : 0.8
                withAnimation(.easeOut(duration: duration)) {
                    showContent = true
                }
            }
        }
    }
}

// MARK: - FeaturePreviewModal

struct FeaturePreviewModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    private let features = [
        FeaturePreview(
            title: "AI Trade Insights",
            description: "Get smart recommendations based on player form, fixtures, and advanced analytics. Never make a bad trade again.",
            icon: "brain.head.profile",
            color: .blue
        ),
        FeaturePreview(
            title: "Captain Advisor",
            description: "Advanced algorithm analyzes venue performance, weather conditions, and matchup data to suggest the optimal captain choice.",
            icon: "star.fill",
            color: .yellow
        ),
        FeaturePreview(
            title: "Cash Cow Tracker",
            description: "Identify breakout players before they peak in price. Automated alerts for optimal buy/sell windows.",
            icon: "dollarsign.circle.fill",
            color: .green
        ),
        FeaturePreview(
            title: "Performance Analytics",
            description: "Deep dive into player stats, consistency scores, and injury risk assessments with interactive charts.",
            icon: "chart.bar.fill",
            color: .purple
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<features.count, id: \.self) { index in
                            Button {
                                selectedTab = index
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: features[index].icon)
                                        .font(.title2)
                                        .foregroundColor(selectedTab == index ? features[index].color : .secondary)
                                    
                                    Text(features[index].title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedTab == index ? .primary : .secondary)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedTab == index ? features[index].color.opacity(0.1) : Color.clear)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Feature content
                TabView(selection: $selectedTab) {
                    ForEach(0..<features.count, id: \.self) { index in
                        FeaturePreviewCard(feature: features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // CTA
                VStack(spacing: 16) {
                    Button("Start Using AFL Fantasy Intelligence") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("Ready to dominate your league?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("App Features")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - FeaturePreview

struct FeaturePreview {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - FeaturePreviewCard

struct FeaturePreviewCard: View {
    let feature: FeaturePreview
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: feature.icon)
                .font(.system(size: 60))
                .foregroundColor(feature.color)
                .padding(.top)
            
            // Content
            VStack(spacing: 16) {
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
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

// MARK: - TeamChoiceView

struct TeamChoiceView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var selectedFeature = 0

    private let features = [
        ("🧠", "AI Trade Insights", "Smart recommendations powered by real-time data"),
        ("⭐", "Captain Advisor", "Advanced analytics for captain selection"),
        ("📊", "Performance Tracking", "Detailed player stats and projections"),
        ("💰", "Cash Cow Alerts", "Never miss optimal buy/sell windows")
    ]

    var body: some View {
        VStack(spacing: 40) {
            // Progress indicator
            OnboardingProgressBar(
                progress: coordinator.progress,
                totalSteps: coordinator.currentStep.totalSteps
            )
            .padding(.horizontal)
            // Header
            VStack(spacing: 16) {
                Text("🏈")
                    .font(.system(size: 60))

                Text("Let's Set Up Your Team")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Do you already have an AFL Fantasy team for this season?")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }

            // Feature Carousel
            VStack(spacing: 12) {
                TabView(selection: $selectedFeature) {
                    ForEach(0 ..< features.count, id: \.self) { index in
                        FeatureCard(feature: features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 120)

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0 ..< features.count, id: \.self) { index in
                        Circle()
                            .fill(selectedFeature == index ? .white : .white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }

            Spacer()

            // Choice Buttons
            VStack(spacing: 20) {
                Button {
                    coordinator.selectHasExistingTeam()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Connect Existing Team")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Text("I already have an AFL Fantasy team")
                                .font(.caption)
                                .opacity(0.8)
                        }

                        Spacer()

                        Image(systemName: "link")
                            .font(.title2)
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .background(.white)
                    .cornerRadius(16)
                }
                .accessibilityLabel("Connect existing AFL Fantasy team")
                .accessibilityHint("Tap to connect your existing team and get personalized insights")

                Button {
                    coordinator.selectNeedsToCreateTeam()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I Need to Create One")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Text("Show me how to set up a new team")
                                .font(.caption)
                                .opacity(0.8)
                        }

                        Spacer()

                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .background(.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.5), lineWidth: 2)
                    )
                }
                .accessibilityLabel("Create new AFL Fantasy team")
                .accessibilityHint("Tap to get guided instructions for creating your first team")

                // Back button
                Button("Back") {
                    coordinator.previousStep()
                }
                .foregroundColor(.white.opacity(0.7))
                .font(.body)
                .padding(.top)
            }
        }
        .padding()
        .onAppear {
            // Auto-advance feature carousel
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedFeature = (selectedFeature + 1) % features.count
                }
            }
        }
    }
}

// MARK: - FeatureCard

struct FeatureCard: View {
    let feature: (String, String, String)

    var body: some View {
        VStack(spacing: 8) {
            Text(feature.0)
                .font(.title)

            Text(feature.1)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(feature.2)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - CreateTeamGuideView

struct CreateTeamGuideView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    @State private var showCompletedSteps: Set<Int> = []
    @State private var timeSpent: Date = .init()

    private let setupSteps = [
        ("🌐", "Visit AFL Fantasy Website", "Go to fantasy.afl.com.au to get started"),
        ("📝", "Create Your Account", "Sign up with your email and create a password"),
        ("🏈", "Join or Create a League", "Either join an existing league or start your own"),
        ("⭐", "Draft Your Team", "Select your starting squad within the salary cap"),
        ("🔢", "Find Your Team ID", "Note the number in the URL after '/team/' - you'll need this")
    ]

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Text("📋")
                    .font(.system(size: 60))

                Text("Let's Create Your AFL Fantasy Team")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Follow these steps to set up your team. It only takes a few minutes!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }

            // Setup Steps Checklist
            VStack(spacing: 16) {
                ForEach(Array(setupSteps.enumerated()), id: \.offset) { index, step in
                    SetupStepRow(
                        step: step,
                        isCompleted: showCompletedSteps.contains(index),
                        onToggle: {
                            if showCompletedSteps.contains(index) {
                                showCompletedSteps.remove(index)
                            } else {
                                showCompletedSteps.insert(index)
                            }
                        }
                    )
                }
            }

            // Open Website Button
            Link(destination: URL(string: "https://fantasy.afl.com.au")!) {
                HStack {
                    Image(systemName: "safari")
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Open AFL Fantasy Website")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("Opens in Safari browser")
                            .font(.caption)
                            .opacity(0.8)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal)
                .background(.white)
                .cornerRadius(12)
            }
            .accessibilityLabel("Open AFL Fantasy website in Safari")

            Spacer()

            // Navigation Buttons
            VStack(spacing: 16) {
                Button("I've Created My Team") {
                    coordinator.returnFromCreateGuide()
                }
                .buttonStyle(OnboardingButtonStyle())
                .disabled(showCompletedSteps.count < 4) // Need at least 4 steps completed

                HStack(spacing: 16) {
                    Button("Back") {
                        coordinator.previousStep()
                    }
                    .buttonStyle(OnboardingSecondaryButtonStyle())

                    Button("Skip This Step") {
                        coordinator.returnFromCreateGuide()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
                }
            }
        }
        .padding()
        .onDisappear {
            // Track analytics - time spent on team creation guide
            let timeSpent = Date().timeIntervalSince(timeSpent)
            print("CreateTeamGuide: User spent \(Int(timeSpent)) seconds on guide")
        }
    }
}

// MARK: - SetupStepRow

struct SetupStepRow: View {
    let step: (String, String, String)
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Step emoji and checkbox
                ZStack {
                    Circle()
                        .fill(isCompleted ? .white : .white.opacity(0.1))
                        .frame(width: 44, height: 44)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .fontWeight(.bold)
                    } else {
                        Text(step.0)
                            .font(.title2)
                    }
                }

                // Step content
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.1)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    Text(step.2)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? .white.opacity(0.1) : .clear)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(step.1): \(step.2)")
        .accessibilityValue(isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Tap to mark as completed")
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
            // Progress indicator
            OnboardingProgressBar(
                progress: coordinator.progress,
                totalSteps: coordinator.currentStep.totalSteps
            )
            .padding(.horizontal)
            
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
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                    }

                    TextField("e.g., 123456", text: $coordinator.teamId)
                        .textFieldStyle(OnboardingTextFieldStyle())
                        .keyboardType(.numberPad)
                }

                // Session Cookie Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Session Cookie")
                            .font(.headline)
                            .foregroundColor(.white)

                        Button("?") {
                            showHelp.toggle()
                        }
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                    }

                    TextField("Paste your session cookie here", text: $coordinator.sessionCookie)
                        .textFieldStyle(OnboardingTextFieldStyle())
                }
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
        .alert("Validation Error", isPresented: $coordinator.showValidationAlert) {
            if let error = coordinator.validationError {
                if error.canRetry && !coordinator.shouldShowSupportOption() {
                    Button("Try Again") {
                        coordinator.retryValidation()
                    }
                    Button("Edit Credentials") {
                        coordinator.showValidationAlert = false
                    }
                } else if coordinator.shouldShowSupportOption() {
                    Button("Edit Credentials") {
                        coordinator.showValidationAlert = false
                    }
                    Button("Get Help") {
                        // Open support email or help
                        showHelp = true
                        coordinator.showValidationAlert = false
                    }
                } else {
                    Button("OK") {
                        coordinator.showValidationAlert = false
                    }
                }
            }
        } message: {
            if let error = coordinator.validationError {
                VStack(alignment: .leading, spacing: 8) {
                    Text(error.errorDescription ?? "Unknown error")
                    Text(error.recoveryMessage)
                        .font(.caption)
                }
            }
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

// MARK: - OnboardingProgressBar

struct OnboardingProgressBar: View {
    let progress: Double
    let totalSteps: Int

    var body: some View {
        VStack(spacing: 8) {
            // Progress dots
            HStack(spacing: 12) {
                ForEach(0 ..< totalSteps, id: \.self) { step in
                    Circle()
                        .fill(Double(step) <= progress * Double(totalSteps) ? .white : .white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.3))
                        .frame(height: 4)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView {
        print("Onboarding completed!")
    }
}
