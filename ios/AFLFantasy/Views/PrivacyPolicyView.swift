//
//  PrivacyPolicyView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - PrivacyPolicyView

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityTraits(.header)

                    Text("Last updated: September 6, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Group {
                        privacySection(
                            title: "Information We Collect",
                            content: "AFL Fantasy Intelligence collects data necessary to provide fantasy football insights including team selections, player preferences, and usage analytics."
                        )

                        privacySection(
                            title: "How We Use Your Information",
                            content: "Your data is used to provide personalized fantasy recommendations, improve app performance, and deliver relevant notifications about your team."
                        )

                        privacySection(
                            title: "Data Storage & Security",
                            content: "All sensitive data is encrypted and stored securely using industry-standard practices. We do not share personal information with third parties."
                        )

                        privacySection(
                            title: "Your Rights",
                            content: "You can request data deletion, modify privacy settings, or export your data at any time through the app settings."
                        )

                        privacySection(
                            title: "Contact Us",
                            content: "Questions about privacy? Contact us at privacy@afl.ai or through the app feedback system."
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
                    .accessibilityLabel("Close privacy policy")
                }
            }
        }
    }

    @ViewBuilder
    private func privacySection(title: String, content: String) -> some View {
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
    PrivacyPolicyView()
}
