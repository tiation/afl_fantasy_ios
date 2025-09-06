//
//  TermsOfUseView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        LegalDocumentContainer(
            title: "Terms of Use",
            onDismiss: { presentationMode.wrappedValue.dismiss() }
        ) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                Group {
                    Text("AFL Fantasy Intelligence Platform")
                        .legalDocumentTitle()

                    Text("Last updated: September 6, 2025 • Version 1.0")
                        .font(.caption)
                        .foregroundColor(LegalDocumentStyle.Colors.secondaryText)
                        .padding(.bottom, 16)
                }

                // Acceptance of terms
                Group {
                    Text("1. Acceptance of Terms")
                        .legalSectionHeader()

                    Text(
                        "By downloading, installing, or using AFL Fantasy Intelligence Platform (\"the App\"), you agree to be bound by these Terms of Use. If you do not agree to these terms, do not use the App."
                    )
                    .legalBody()

                    Text(
                        "These terms constitute a legally binding agreement between you and AFL Fantasy Intelligence Platform (\"we,\" \"our,\" or \"us\")."
                    )
                    .legalBody()
                }

                LegalSectionDivider()

                // Eligibility
                Group {
                    Text("2. Eligibility and Account Requirements")
                        .legalSectionHeader()

                    Text("Age Requirements")
                        .legalSubsectionHeader()

                    Group {
                        Text("• You must be at least 13 years old to use this App")
                            .legalBulletPoint()
                        Text("• If you are under 18, you must have parental consent to use fantasy sports applications")
                            .legalBulletPoint()
                        Text(
                            "• Users under 18 should be supervised by a parent or guardian when making any fantasy-related decisions"
                        )
                        .legalBulletPoint()
                    }

                    ImportantDisclaimerBox(
                        title: "No Gambling or Wagering",
                        content: "This App is NOT a gambling or wagering platform. No real money transactions, betting, or wagering occurs within the App. The App is designed for entertainment and educational purposes related to fantasy sports. We do not facilitate, promote, or endorse any form of gambling or betting."
                    )
                }

                LegalSectionDivider()

                // Fantasy projections disclaimer
                Group {
                    Text("3. Fantasy Projections and Statistical Disclaimers")
                        .legalSectionHeader()

                    Text("Nature of Predictions")
                        .legalSubsectionHeader()

                    Text("Our App provides fantasy football analysis, player projections, and recommendations based on:"
                    )
                    .legalBody()

                    Group {
                        Text("• Historical player performance data")
                            .legalBulletPoint()
                        Text("• Statistical modeling and algorithms")
                            .legalBulletPoint()
                        Text("• Publicly available AFL statistics")
                            .legalBulletPoint()
                        Text("• Weather and venue analysis")
                            .legalBulletPoint()
                    }

                    ImportantDisclaimerBox(
                        title: "IMPORTANT ACCURACY DISCLAIMER",
                        content: "All predictions, projections, and recommendations are estimates only and should be treated as entertainment. No guarantee of accuracy: Player projections may be significantly different from actual performance. Past performance does not indicate future results. External factors: Injuries, weather, team changes, and other unpredictable factors affect real performance. Statistical limitations: Our models have inherent limitations and margins of error."
                    )

                    Text("Prediction Limits and Usage Guidelines")
                        .legalSubsectionHeader()

                    Text("This App provides informational content only and should NOT be used as:")
                        .legalImportantText()

                    Group {
                        Text("• The sole basis for any financial decisions")
                            .legalBulletPoint()
                        Text("• Gambling advice or betting recommendations")
                            .legalBulletPoint()
                        Text("• Professional sports analysis")
                            .legalBulletPoint()
                        Text("• Investment guidance")
                            .legalBulletPoint()
                    }

                    Text("Recommended use:")
                        .font(.body.weight(.medium))
                        .foregroundColor(LegalDocumentStyle.Colors.helplineText)
                        .padding(.top, 8)

                    Group {
                        Text("• Entertainment and general interest in fantasy sports")
                            .legalBulletPoint()
                        Text("• Educational tool to understand statistical analysis")
                            .legalBulletPoint()
                        Text("• One of many factors when making fantasy team decisions")
                            .legalBulletPoint()
                        Text("• General AFL knowledge and appreciation")
                            .legalBulletPoint()
                    }
                }

                LegalSectionDivider()

                // Responsible gambling section
                Group {
                    Text("4. Responsible Gaming and Gambling Help")
                        .legalSectionHeader()

                    ImportantDisclaimerBox(
                        title: "Important Notice About Gambling",
                        content: "While our App does not involve gambling, we recognize that some users may also participate in other fantasy sports or betting activities. If you or someone you know has concerns about gambling, help is available:"
                    )

                    Text("Australia - Gambling Help Resources")
                        .legalSubsectionHeader()

                    VStack(alignment: .leading, spacing: 12) {
                        HelpResourceLink(
                            "National Gambling Helpline",
                            url: "tel:1800858858",
                            phone: "1800 858 858"
                        )

                        HelpResourceLink(
                            "Gambling Help Online",
                            url: "https://www.gamblinghelponline.org.au"
                        )

                        HelpResourceLink(
                            "BetStop National Self-Exclusion Register",
                            url: "https://www.betstop.gov.au"
                        )

                        HelpResourceLink(
                            "NSW Gambling Help",
                            url: "https://www.gambleaware.nsw.gov.au"
                        )

                        HelpResourceLink(
                            "Victoria - Responsible Gambling",
                            url: "https://www.responsiblegambling.vic.gov.au"
                        )
                    }
                    .padding(.vertical, 8)

                    Text("International Resources")
                        .legalSubsectionHeader()

                    VStack(alignment: .leading, spacing: 8) {
                        HelpResourceLink(
                            "UK - GamCare",
                            url: "https://www.gamcare.org.uk",
                            phone: "0808 8020 133"
                        )

                        HelpResourceLink(
                            "USA - National Problem Gambling Helpline",
                            url: "https://www.ncpgambling.org",
                            phone: "1-800-522-4700"
                        )

                        HelpResourceLink(
                            "Canada - Problem Gambling Institute",
                            url: "https://www.problemgambling.ca"
                        )
                    }
                    .padding(.vertical, 8)

                    Text("Signs of Gambling Problems")
                        .legalSubsectionHeader()

                    Text("Please seek help if you or someone you know:")
                        .legalBody()

                    Group {
                        Text("• Spends more money on gambling than intended")
                            .legalBulletPoint()
                        Text("• Lies about gambling activities")
                            .legalBulletPoint()
                        Text("• Borrows money to gamble")
                            .legalBulletPoint()
                        Text("• Neglects responsibilities due to gambling")
                            .legalBulletPoint()
                        Text("• Feels anxious or depressed about gambling")
                            .legalBulletPoint()
                    }

                    Text(
                        "Remember: Fantasy sports should be fun and entertaining. Never risk more than you can afford to lose."
                    )
                    .font(.body.weight(.medium))
                    .foregroundColor(LegalDocumentStyle.Colors.helplineText)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LegalDocumentStyle.Colors.helplineText.opacity(0.1))
                    )
                    .padding(.vertical, 8)
                }

                LegalSectionDivider()

                // Limitation of liability
                Group {
                    Text("5. Limitation of Liability and Disclaimers")
                        .legalSectionHeader()

                    Text("No Warranties")
                        .legalSubsectionHeader()

                    Text("THE APP IS PROVIDED \"AS IS\" WITHOUT WARRANTIES OF ANY KIND, including but not limited to:")
                        .legalImportantText()

                    Group {
                        Text("• Accuracy of predictions or statistics")
                            .legalBulletPoint()
                        Text("• Uninterrupted or error-free operation")
                            .legalBulletPoint()
                        Text("• Compatibility with your device")
                            .legalBulletPoint()
                        Text("• Achievement of any particular fantasy results")
                            .legalBulletPoint()
                    }

                    Text("Limitation of Liability")
                        .legalSubsectionHeader()

                    Text("We are not liable for:")
                        .legalImportantText()

                    Group {
                        Text("• Fantasy team performance based on our recommendations")
                            .legalBulletPoint()
                        Text("• Losses in fantasy leagues or competitions")
                            .legalBulletPoint()
                        Text("• Any financial losses resulting from use of our predictions")
                            .legalBulletPoint()
                        Text("• Decisions made based on App recommendations")
                            .legalBulletPoint()
                        Text("• Indirect, incidental, or consequential damages of any kind")
                            .legalBulletPoint()
                    }

                    Text("Maximum Liability")
                        .legalSubsectionHeader()

                    Text(
                        "In no event shall our total liability exceed the amount you paid for the App (which is currently free)."
                    )
                    .legalBody()
                }

                LegalSectionDivider()

                // Intellectual property
                Group {
                    Text("6. Intellectual Property Rights")
                        .legalSectionHeader()

                    Text("Our Content")
                        .legalSubsectionHeader()

                    Group {
                        Text("• App design, code, algorithms, and user interface are our intellectual property")
                            .legalBulletPoint()
                        Text("• Statistical analysis methods and prediction models are proprietary")
                            .legalBulletPoint()
                        Text("• You may not copy, distribute, or create derivative works without permission")
                            .legalBulletPoint()
                    }

                    Text("AFL and Third-Party Content")
                        .legalSubsectionHeader()

                    Group {
                        Text("• AFL trademarks and logos are property of the Australian Football League (AFL) © AFL")
                            .legalBulletPoint()
                        Text("• Player statistics and team information are used under fair use for statistical analysis"
                        )
                        .legalBulletPoint()
                        Text("• We are not affiliated with or endorsed by the AFL, AFL teams, or players")
                            .legalBulletPoint()
                        Text("• Team names, player names, and statistics are used for informational purposes only")
                            .legalBulletPoint()
                    }
                }

                LegalSectionDivider()

                // Governing law
                Group {
                    Text("7. Governing Law and Dispute Resolution")
                        .legalSectionHeader()

                    Text(
                        "These Terms are governed by the laws of Victoria, Australia, without regard to conflict of law principles."
                    )
                    .legalBody()

                    Text("For disputes:")
                        .legalBody()

                    Group {
                        Text("1. Contact us first at legal@afl.ai to resolve disputes")
                            .legalBulletPoint()
                        Text("2. If informal resolution fails, disputes should be resolved through mediation")
                            .legalBulletPoint()
                        Text("3. Any legal proceedings will be conducted in the courts of Victoria, Australia")
                            .legalBulletPoint()
                    }
                }

                LegalSectionDivider()

                // Contact information
                Group {
                    Text("8. Contact Information and Support")
                        .legalSectionHeader()

                    Text("Questions About These Terms")
                        .legalSubsectionHeader()

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Email:")
                                .font(.body.weight(.medium))
                            if let emailURL = URL(string: "mailto:legal@afl.ai") {
                                Link("legal@afl.ai", destination: emailURL)
                                    .legalContactText()
                            }
                        }

                        Text("• Subject line: \"Terms of Use Question\"")
                            .legalBulletPoint()
                        Text("• Response time: 5-10 business days")
                            .legalBulletPoint()
                    }

                    Text("App Support and Technical Issues")
                        .legalSubsectionHeader()

                    Group {
                        Text("• In-app: Settings → \"Report Issue\"")
                            .legalBulletPoint()
                        Text("• Email: support@afl.ai")
                            .legalBulletPoint()
                        Text("• Response time: 2-5 business days")
                            .legalBulletPoint()
                    }
                }

                // Summary for users
                VStack(alignment: .leading, spacing: 12) {
                    LegalSectionDivider()

                    Text("Summary for Users")
                        .font(.title3.bold())
                        .foregroundColor(LegalDocumentStyle.Colors.accent)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Points:")
                            .font(.body.weight(.medium))

                        Group {
                            Text("1. This is NOT a gambling app - we provide fantasy sports entertainment only")
                                .legalBulletPoint()
                            Text("2. Our predictions are estimates - they may be wrong, use for fun only")
                                .legalBulletPoint()
                            Text("3. Get help if you have gambling problems - call 1800 858 858 in Australia")
                                .legalBulletPoint()
                            Text("4. We don't collect your personal data - everything stays on your device")
                                .legalBulletPoint()
                            Text("5. You must be 13+ to use - parental supervision recommended under 18")
                                .legalBulletPoint()
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LegalDocumentStyle.Colors.accent.opacity(0.1))
                    )

                    Text(
                        "Thank you for using AFL Fantasy Intelligence Platform responsibly and for entertainment purposes."
                    )
                    .font(.body.weight(.medium))
                    .foregroundColor(LegalDocumentStyle.Colors.text)
                    .padding(.top, 16)

                    Text("Last updated: September 6, 2025")
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
    TermsOfUseView()
}
