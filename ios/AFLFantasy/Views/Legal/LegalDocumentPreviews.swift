//
//  LegalDocumentPreviews.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - LegalDocumentPreviews

struct LegalDocumentPreviews: View {
    @State private var showingPrivacy = false
    @State private var showingTerms = false
    @State private var isDarkMode = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Legal Document Test")
                    .font(.title)
                    .bold()

                Toggle("Dark Mode Preview", isOn: $isDarkMode)
                    .padding()

                Button("Show Privacy Policy") {
                    showingPrivacy = true
                }
                .buttonStyle(.borderedProminent)

                Button("Show Terms of Use") {
                    showingTerms = true
                }
                .buttonStyle(.borderedProminent)

                Spacer()

                // Test different text sizes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accessibility Test:")
                        .font(.headline)

                    Text("Legal documents support:")
                        .legalBody()

                    Text("• Dynamic Type scaling")
                        .legalBulletPoint()
                    Text("• VoiceOver compatibility")
                        .legalBulletPoint()
                    Text("• High contrast colors")
                        .legalBulletPoint()
                    Text("• Native iOS gestures")
                        .legalBulletPoint()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
            }
            .navigationTitle("Legal Test")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyPolicyView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .sheet(isPresented: $showingTerms) {
            TermsOfUseView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - LegalComponentTests

struct LegalComponentTests: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Legal Component Tests")
                    .font(.title)
                    .bold()
                    .padding(.bottom)

                // Test ImportantDisclaimerBox
                ImportantDisclaimerBox(
                    title: "Test Disclaimer",
                    content: "This is a test of the important disclaimer box component. It should have proper styling in both light and dark modes."
                )

                // Test HelpResourceLink
                VStack(alignment: .leading, spacing: 8) {
                    Text("Help Resource Links:")
                        .font(.headline)

                    HelpResourceLink(
                        "Test Gambling Helpline",
                        url: "tel:1800858858",
                        phone: "1800 858 858"
                    )

                    HelpResourceLink(
                        "Test Website",
                        url: "https://example.com"
                    )
                }

                // Test section styling
                VStack(alignment: .leading, spacing: 8) {
                    Text("Typography Test")
                        .legalSectionHeader()

                    Text("Regular body text")
                        .legalBody()

                    Text("Important text")
                        .legalImportantText()

                    Text("Help line text")
                        .legalHelplineText()

                    Text("Contact text")
                        .legalContactText()
                }

                LegalSectionDivider()

                Text("All components should adapt to:")
                    .font(.headline)

                VStack(alignment: .leading) {
                    Text("• System dark/light mode")
                        .legalBulletPoint()
                    Text("• Dynamic Type sizes")
                        .legalBulletPoint()
                    Text("• High contrast mode")
                        .legalBulletPoint()
                    Text("• Accessibility features")
                        .legalBulletPoint()
                }
            }
            .padding()
        }
    }
}

// MARK: - Previews

#Preview("Legal Document Previews") {
    LegalDocumentPreviews()
}

#Preview("Privacy Policy Light") {
    PrivacyPolicyView()
        .preferredColorScheme(.light)
}

#Preview("Privacy Policy Dark") {
    PrivacyPolicyView()
        .preferredColorScheme(.dark)
}

#Preview("Terms of Use Light") {
    TermsOfUseView()
        .preferredColorScheme(.light)
}

#Preview("Terms of Use Dark") {
    TermsOfUseView()
        .preferredColorScheme(.dark)
}

#Preview("Component Tests") {
    LegalComponentTests()
}

#Preview("Component Tests Dark") {
    LegalComponentTests()
        .preferredColorScheme(.dark)
}
