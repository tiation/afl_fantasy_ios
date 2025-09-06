//
//  PrivacyPolicyView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        LegalDocumentContainer(
            title: "Privacy Policy",
            onDismiss: { presentationMode.wrappedValue.dismiss() }
        ) {
            VStack(alignment: .leading, spacing: 0) {
                // Header with version info
                Group {
                    Text("AFL Fantasy Intelligence Platform")
                        .legalDocumentTitle()

                    Text("Last updated: September 6, 2025 • Version 1.0")
                        .font(.caption)
                        .foregroundColor(LegalDocumentStyle.Colors.secondaryText)
                        .padding(.bottom, 16)
                }

                // Introduction
                Group {
                    Text("1. Introduction")
                        .legalSectionHeader()

                    Text(
                        "AFL Fantasy Intelligence Platform ("we,
                        " "our,
                        " or "the App") is committed to protecting your privacy. This Privacy Policy explains how we handle information when you use our AFL Fantasy analysis and prediction app."
                    )
                    .legalBody()

                    ImportantDisclaimerBox(
                        title: "Key Principle",
                        content: "We do not collect, store, or share your personal information online. All data processing happens locally on your device."
                    )
                }

                LegalSectionDivider()

                // What we don't collect
                Group {
                    Text("2. Information We Do NOT Collect")
                        .legalSectionHeader()

                    Text("We do not collect, store, or have access to:")
                        .legalBody()

                    Group {
                        Text("• Personal identification information (name, email, phone number)")
                            .legalBulletPoint()
                        Text("• Location data or GPS coordinates")
                            .legalBulletPoint()
                        Text("• Photos, contacts, or camera access")
                            .legalBulletPoint()
                        Text("• Social media accounts or profiles")
                            .legalBulletPoint()
                        Text("• Payment or financial information")
                            .legalBulletPoint()
                        Text("• Device identifiers that can track you across apps")
                            .legalBulletPoint()
                        Text("• Analytics or usage tracking data")
                            .legalBulletPoint()
                        Text("• Any information that leaves your device")
                            .legalBulletPoint()
                    }
                }

                LegalSectionDivider()

                // Local data storage
                Group {
                    Text("3. Local Data Storage and Usage")
                        .legalSectionHeader()

                    Text("What is stored locally on your device:")
                        .legalSubsectionHeader()

                    Group {
                        Text("• Fantasy player statistics and projections downloaded from public AFL sources")
                            .legalBulletPoint()
                        Text("• App preferences and settings (notifications, display options)")
                            .legalBulletPoint()
                        Text("• Cached data to improve app performance and offline usage")
                            .legalBulletPoint()
                        Text("• User selections (captain choices, trade preferences)")
                            .legalBulletPoint()
                    }

                    Text("How this local data is used:")
                        .legalSubsectionHeader()

                    Group {
                        Text("• Generate personalized fantasy football recommendations")
                            .legalBulletPoint()
                        Text("• Display player statistics, scores, and projections")
                            .legalBulletPoint()
                        Text("• Provide captain advisor suggestions")
                            .legalBulletPoint()
                        Text("• Calculate trade recommendations and cash cow analysis")
                            .legalBulletPoint()
                        Text("• Cache data for faster loading and offline access")
                            .legalBulletPoint()
                    }

                    Text("Managing your local data:")
                        .legalSubsectionHeader()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("You have full control over local data:")
                            .legalBody()

                        Group {
                            Text(
                                "• Clear Cache: Go to Settings → Data → \"Clear Cache\" to delete all stored fantasy data"
                            )
                            .legalBulletPoint()
                            Text("• Reset App: Delete and reinstall the app to remove all local data")
                                .legalBulletPoint()
                            Text("• Notification Settings: Control alert preferences in Settings → Notifications")
                                .legalBulletPoint()
                        }
                    }
                }

                LegalSectionDivider()

                // No data sharing
                Group {
                    Text("4. No Data Sharing or Sale")
                        .legalSectionHeader()

                    Text("We never sell, share, rent, or transfer your information because:")
                        .legalBody()

                    Group {
                        Text("• We don't collect personal information")
                            .legalBulletPoint()
                        Text("• All processing happens locally on your device")
                            .legalBulletPoint()
                        Text("• We have no servers storing your data")
                            .legalBulletPoint()
                        Text("• We have no advertising or analytics partners")
                            .legalBulletPoint()
                        Text("• We don't use third-party tracking services")
                            .legalBulletPoint()
                    }
                }

                LegalSectionDivider()

                // Data security
                Group {
                    Text("5. Data Security")
                        .legalSectionHeader()

                    Text("While we don't collect personal data, we protect the local data on your device through:")
                        .legalBody()

                    Group {
                        Text("• Device keychain storage for sensitive app preferences")
                            .legalBulletPoint()
                        Text("• Encryption at rest for locally cached data")
                            .legalBulletPoint()
                        Text("• Secure network connections (HTTPS) when downloading public AFL data")
                            .legalBulletPoint()
                        Text("• Regular security updates following Apple's security guidelines")
                            .legalBulletPoint()
                    }
                }

                LegalSectionDivider()

                // Third-party services
                Group {
                    Text("6. Third-Party Services")
                        .legalSectionHeader()

                    Text("AFL Data Sources")
                        .legalSubsectionHeader()

                    Text(
                        "We retrieve public AFL fantasy statistics from official sources. These are publicly available statistics and do not contain personal information."
                    )
                    .legalBody()

                    Text("Apple Services")
                        .legalSubsectionHeader()

                    Text("We may use Apple's built-in services like:")
                        .legalBody()

                    Group {
                        Text("• Sign in with Apple (optional, for future features)")
                            .legalBulletPoint()
                        Text("• App Store for app distribution")
                            .legalBulletPoint()
                        Text("• iOS system features (notifications, settings)")
                            .legalBulletPoint()
                    }

                    Text("These services have their own privacy policies and data handling practices.")
                        .legalBody()
                }

                LegalSectionDivider()

                // Children's privacy
                Group {
                    Text("7. Children's Privacy")
                        .legalSectionHeader()

                    Text(
                        "Our app is rated 12+ in the App Store. We do not knowingly collect personal information from children under 13. Since we don't collect personal information at all, this policy applies universally."
                    )
                    .legalBody()

                    Text(
                        "If you're under 18, please ensure you have parental permission before using fantasy sports apps."
                    )
                    .legalBody()
                }

                LegalSectionDivider()

                // Contact information
                Group {
                    Text("8. Contact Information")
                        .legalSectionHeader()

                    Text("For privacy questions or concerns:")
                        .legalBody()

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Email:")
                                .font(.body.weight(.medium))
                            if let emailURL = URL(string: "mailto:legal@afl.ai") {
                                Link("legal@afl.ai", destination: emailURL)
                                    .legalContactText()
                            }
                        }

                        Text("• App Support: Use the in-app feedback feature in Settings")
                            .legalBulletPoint()
                        Text("• Response time: We aim to respond within 5 business days")
                            .legalBulletPoint()
                    }
                }

                LegalSectionDivider()

                // Your rights
                Group {
                    Text("9. Your Rights")
                        .legalSectionHeader()

                    Text("Even though we don't collect personal data, you always have the right to:")
                        .legalBody()

                    Group {
                        Text("• Access: View what data is stored locally (Settings → Data)")
                            .legalBulletPoint()
                        Text("• Delete: Clear all local data (Settings → Clear Cache)")
                            .legalBulletPoint()
                        Text("• Control: Manage all app permissions in iOS Settings")
                            .legalBulletPoint()
                        Text("• Withdraw: Stop using the app at any time")
                            .legalBulletPoint()
                    }
                }

                // Summary
                VStack(alignment: .leading, spacing: 12) {
                    LegalSectionDivider()

                    Text("Summary")
                        .font(.title3.bold())
                        .foregroundColor(LegalDocumentStyle.Colors.accent)

                    Text(
                        "We respect your privacy by not collecting any personal information. Everything happens locally on your device, giving you complete control over your data."
                    )
                    .font(.body.weight(.medium))
                    .foregroundColor(LegalDocumentStyle.Colors.text)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LegalDocumentStyle.Colors.accent.opacity(0.1))
                    )

                    Text(
                        "This policy is written in plain English to be easily understood. If you have questions, please contact us at legal@afl.ai."
                    )
                    .font(.caption)
                    .foregroundColor(LegalDocumentStyle.Colors.secondaryText)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PrivacyPolicyView()
}
