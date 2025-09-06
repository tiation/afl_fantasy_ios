//
//  TermsOfUseView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - TermsOfUseView

struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityTraits(.header)

                    Text("Last updated: September 6, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Group {
                        termsSection(
                            title: "Acceptance of Terms",
                            content: "By using AFL Fantasy Intelligence, you agree to these Terms of Service and our Privacy Policy. These terms may be updated periodically."
                        )

                        termsSection(
                            title: "App Usage",
                            content: "This app provides fantasy football insights and recommendations. All data is for informational purposes only and should not be considered professional financial advice."
                        )

                        termsSection(
                            title: "User Responsibilities",
                            content: "Users are responsible for maintaining account security, providing accurate information, and using the app in compliance with applicable laws."
                        )

                        termsSection(
                            title: "Intellectual Property",
                            content: "AFL Fantasy Intelligence and all related content, features, and functionality are owned by AFL AI and protected by copyright and trademark laws."
                        )

                        termsSection(
                            title: "Limitation of Liability",
                            content: "The app is provided 'as is' without warranties. We are not liable for any damages arising from app usage or fantasy sports decisions."
                        )

                        termsSection(
                            title: "Contact Information",
                            content: "Questions about these terms? Contact us at legal@afl.ai or through the app support system."
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close terms of service")
                }
            }
        }
    }

    @ViewBuilder
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .accessibilityTraits(.header)

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    TermsOfUseView()
}
