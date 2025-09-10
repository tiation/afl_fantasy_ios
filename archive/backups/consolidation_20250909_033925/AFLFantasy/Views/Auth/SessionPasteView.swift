//
//  SessionPasteView.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced session clipboard detection and paste UI
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - SessionPasteView

struct SessionPasteView: View {
    @EnvironmentObject private var dataService: AFLFantasyDataService
    @Environment(\.colorScheme) private var colorScheme

    // View state
    @State private var isCheckingClipboard = false
    @State private var sessionInput = ""
    @State private var sessionPreview: CookieExtractionResult?
    @State private var showingHelp = false
    @State private var clipboardResults: [CookieExtractionResult] = []
    @State private var activeSheet: ActiveSheet?

    // Animation state
    @State private var hasClipboardContent = false
    @State private var showPasteAnimation = false
    @State private var showSuccessState = false
    @State private var isCheckingAnimation = false
    @State private var showCopiedAnimation = false

    // Error handling
    @State private var showError = false
    @State private var errorMessage = ""

    // UI Constants
    private let cornerRadius: CGFloat = 12
    private let buttonHeight: CGFloat = 50
    private let horizontalPadding: CGFloat = 20

    private enum ActiveSheet: Identifiable {
        case help
        case clipboardPreview
        case tutorial

        var id: Int {
            switch self {
            case .help: 1
            case .clipboardPreview: 2
            case .tutorial: 3
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if hasClipboardContent {
                    clipboardPreviewSection
                } else {
                    manualInputSection
                }

                actionButtonSection
                helpSection
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Session Setup")
        .animation(.easeInOut, value: isCheckingAnimation)
        .animation(.easeInOut, value: hasClipboardContent)
        .animation(.spring(), value: showSuccessState)
        .navigationBarItems(trailing: helpButton)
        .onAppear {
            checkClipboard()
        }
        .onChange(of: sessionInput) { _ in
            validateSession()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .help:
                SessionHelpSheet()
            case .clipboardPreview:
                ClipboardPreviewSheet(results: clipboardResults) { result in
                    handleClipboardSelection(result)
                }
            case .tutorial:
                TutorialSheet()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .padding(.bottom, 8)

            Text("Let's Link Your Account")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            Text("Add your session ID to sync with AFL Fantasy")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    // MARK: - Clipboard Preview Section

    private var clipboardPreviewSection: some View {
        let scale = showPasteAnimation ? 1.0 : 0.95
        let opacity = showPasteAnimation ? 1.0 : 0.0
        VStack(spacing: 16) {
            if isCheckingAnimation {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Checking clipboard...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.secondarySystemGroupedBackground))
                )
                .transition(.opacity)
            }
            if let preview = sessionPreview, !isCheckingAnimation {
                clipboardContentPreview(preview)
            }

            if clipboardResults.count > 1 {
                Button {
                    activeSheet = .clipboardPreview
                } label: {
                    HStack {
                        Text("View All Formats")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.medium))
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showPasteAnimation)
    }

    private func clipboardContentPreview(_ result: CookieExtractionResult) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label("Found in Clipboard", systemImage: "doc.on.clipboard")
                    .font(.subheadline.weight(.medium))

                Spacer()

                confidenceBadge(result.confidence)
            }

            VStack(spacing: 8) {
                Text("Format: \(result.source.rawValue)")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text(result.cookie)
                    .font(.system(.subheadline, design: .monospaced))
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemFill))
                    )
            }

            Button {
                sessionInput = result.cookie
                showSuccessState = true
                validateSession()
            } label: {
                Label(
                    showSuccessState ? "Session Applied" : "Use This Session",
                    systemImage: showSuccessState ? "checkmark.circle.fill" : "checkmark.circle"
                )
                .font(.subheadline.weight(.medium))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func confidenceBadge(_ confidence: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: confidence > 0.9 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            Text("\(Int(confidence * 100))%")
        }
        .font(.footnote.weight(.medium))
        .foregroundColor(confidence > 0.9 ? .green : .orange)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(confidence > 0.9 ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        )
    }

    // MARK: - Manual Input Section

    private var manualInputSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Session ID")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("Enter your session ID", text: $sessionInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(.body, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Text("Get this from AFL Fantasy website")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }

    // MARK: - Action Button Section

    private var actionButtonSection: some View {
        VStack(spacing: 16) {
            Button {
                handleContinue()
            } label: {
                if dataService.loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Continue")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .disabled(sessionInput.isEmpty || dataService.loading)

            Button {
                activeSheet = .tutorial
            } label: {
                Text("Show me how to find my session ID")
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Help Section

    private var helpSection: some View {
        VStack(spacing: 8) {
            Text("Having trouble?")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button {
                activeSheet = .help
            } label: {
                Text("Get help")
                    .font(.subheadline)
            }
        }
        .padding(.top)
    }

    private var helpButton: some View {
        Button {
            activeSheet = .help
        } label: {
            Image(systemName: "questionmark.circle")
        }
    }

    // MARK: - Helper Methods

    private func checkClipboard() {
        isCheckingClipboard = true
        isCheckingAnimation = true

        // Delay for animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check clipboard content
            clipboardResults = ClipboardHelperEnhanced.analyzeClipboardContent()

            if let bestMatch = clipboardResults.first {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    hasClipboardContent = true
                    sessionPreview = bestMatch
                    showPasteAnimation = true
                    isCheckingAnimation = false
                }
            } else {
                withAnimation {
                    isCheckingAnimation = false
                }
            }

            isCheckingClipboard = false
        }
    }

    private func validateSession() {
        // Basic format validation
        guard !sessionInput.isEmpty else { return }

        let validated = ClipboardHelperEnhanced.debugExtraction(content: sessionInput)
        if validated.isEmpty {
            showError = true
            errorMessage = "Invalid session ID format"
        }
    }

    private func handleClipboardSelection(_ result: CookieExtractionResult) {
        sessionInput = result.cookie
        activeSheet = nil
        validateSession()

        withAnimation {
            showSuccessState = true
        }
    }

    private func handleContinue() {
        Task {
            let result = await dataService.authenticate(
                teamId: "auto",
                sessionCookie: sessionInput,
                apiToken: nil
            )

            switch result {
            case .success:
                // Successfully authenticated, handled by parent view
                break
            case .failure:
                showError = true
                errorMessage = "Unable to authenticate. Please check your session ID and try again."
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        SessionPasteView()
            .environmentObject(AFLFantasyDataService())
    }
}

// MARK: - SessionHelpSheet

struct SessionHelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    helpItem(
                        icon: "doc.on.clipboard",
                        title: "Automatic Detection",
                        description: "Copy your session ID from AFL Fantasy website and it will be detected automatically."
                    )

                    helpItem(
                        icon: "keyboard",
                        title: "Manual Entry",
                        description: "You can also manually paste or type your session ID."
                    )
                }

                Section {
                    Link(destination: URL(string: "https://fantasy.afl.com.au/help/session")!) {
                        Label("View Help Article", systemImage: "safari")
                    }

                    Button {
                        // Open chat/support
                    } label: {
                        Label("Contact Support", systemImage: "message")
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarItems(trailing: dismissButton)
        }
    }

    private func helpItem(icon: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var dismissButton: some View {
        Button("Done") {
            dismiss()
        }
    }
}

// MARK: - ClipboardPreviewSheet

struct ClipboardPreviewSheet: View {
    let results: [CookieExtractionResult]
    let onSelect: (CookieExtractionResult) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(results, id: \.cookie) { result in
                        resultRow(result)
                    }
                } header: {
                    Text("Found \(results.count) possible formats")
                } footer: {
                    Text("Select the best matching format to continue")
                }
            }
            .navigationTitle("Session Formats")
            .navigationBarItems(trailing: dismissButton)
        }
    }

    private func resultRow(_ result: CookieExtractionResult) -> some View {
        Button {
            onSelect(result)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(result.source.rawValue)
                        .font(.headline)
                    Spacer()
                    Text("\(Int(result.confidence * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(result.cookie)
                    .font(.system(.subheadline, design: .monospaced))
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var dismissButton: some View {
        Button("Done") {
            dismiss()
        }
    }
}

// MARK: - TutorialSheet

struct TutorialSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    tutorialStep(
                        number: 1,
                        title: "Open AFL Fantasy Website",
                        description: "Go to fantasy.afl.com.au and sign in to your account.",
                        image: "safari"
                    )

                    tutorialStep(
                        number: 2,
                        title: "Open Developer Tools",
                        description: "Right click anywhere and select 'Inspect' or press Cmd+Option+I.",
                        image: "chevron.left.forwardslash.chevron.right"
                    )

                    tutorialStep(
                        number: 3,
                        title: "Find Session Cookie",
                        description: "Go to Application > Cookies > fantasy.afl.com.au and find 'sessionid'.",
                        image: "magnifyingglass"
                    )

                    tutorialStep(
                        number: 4,
                        title: "Copy Session ID",
                        description: "Copy the Value field of the sessionid cookie.",
                        image: "doc.on.clipboard"
                    )

                    tutorialStep(
                        number: 5,
                        title: "Return to App",
                        description: "The session ID will be automatically detected when you return.",
                        image: "arrow.turn.up.left"
                    )
                }
                .padding()
            }
            .navigationTitle("Find Session ID")
            .navigationBarItems(trailing: dismissButton)
        }
    }

    private func tutorialStep(number: Int, title: String, description: String, image: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.accentColor))

            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: image)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dismissButton: some View {
        Button("Done") {
            dismiss()
        }
    }
}
