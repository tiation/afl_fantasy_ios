//
//  LegalDocumentStyle.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - LegalDocumentStyle

enum LegalDocumentStyle {
    // MARK: - Colors

    enum Colors {
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let text = Color.primary
        static let secondaryText = Color.secondary
        static let accent = Color.orange
        static let linkColor = Color.blue
        static let warningText = Color.red
        static let helplineText = Color.green

        // Dark mode optimized colors
        static let cardBackground = Color(UIColor.secondarySystemBackground)
        static let sectionBackground = Color(UIColor.tertiarySystemBackground)
    }

    // MARK: - Typography

    enum Typography {
        static let documentTitle = Font.largeTitle.bold()
        static let sectionHeader = Font.title2.bold()
        static let subsectionHeader = Font.title3.bold()
        static let body = Font.body
        static let caption = Font.caption
        static let footnote = Font.footnote
    }

    // MARK: - Spacing

    enum Spacing {
        static let documentPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let paragraphSpacing: CGFloat = 16
        static let lineSpacing: CGFloat = 4
        static let buttonPadding: CGFloat = 16
    }

    // MARK: - Animation

    enum Animation {
        static let standardDuration: Double = 0.3
        static let sheetAnimation = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}

// MARK: - Text Style Modifiers

extension View {
    func legalDocumentTitle() -> some View {
        font(LegalDocumentStyle.Typography.documentTitle)
            .foregroundColor(LegalDocumentStyle.Colors.text)
            .multilineTextAlignment(.leading)
    }

    func legalSectionHeader() -> some View {
        font(LegalDocumentStyle.Typography.sectionHeader)
            .foregroundColor(LegalDocumentStyle.Colors.text)
            .padding(.top, LegalDocumentStyle.Spacing.sectionSpacing)
            .padding(.bottom, LegalDocumentStyle.Spacing.lineSpacing)
    }

    func legalSubsectionHeader() -> some View {
        font(LegalDocumentStyle.Typography.subsectionHeader)
            .foregroundColor(LegalDocumentStyle.Colors.text)
            .padding(.top, LegalDocumentStyle.Spacing.paragraphSpacing)
            .padding(.bottom, LegalDocumentStyle.Spacing.lineSpacing)
    }

    func legalBody() -> some View {
        font(LegalDocumentStyle.Typography.body)
            .foregroundColor(LegalDocumentStyle.Colors.text)
            .lineSpacing(2)
            .padding(.bottom, LegalDocumentStyle.Spacing.lineSpacing)
    }

    func legalBulletPoint() -> some View {
        font(LegalDocumentStyle.Typography.body)
            .foregroundColor(LegalDocumentStyle.Colors.text)
            .padding(.leading, 16)
            .padding(.bottom, 4)
    }

    func legalImportantText() -> some View {
        font(LegalDocumentStyle.Typography.body.bold())
            .foregroundColor(LegalDocumentStyle.Colors.warningText)
            .padding(.vertical, 8)
    }

    func legalHelplineText() -> some View {
        font(LegalDocumentStyle.Typography.body)
            .foregroundColor(LegalDocumentStyle.Colors.helplineText)
    }

    func legalContactText() -> some View {
        font(LegalDocumentStyle.Typography.body)
            .foregroundColor(LegalDocumentStyle.Colors.linkColor)
    }
}

// MARK: - Legal Document Container

struct LegalDocumentContainer<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    @ViewBuilder let content: Content

    // Haptic feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: LegalDocumentStyle.Spacing.lineSpacing) {
                    content
                }
                .padding(LegalDocumentStyle.Spacing.documentPadding)
            }
            .background(LegalDocumentStyle.Colors.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: dismissButton)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var dismissButton: some View {
        Button("Close") {
            impactFeedback.impactOccurred()
            onDismiss()
        }
        .font(.body.weight(.medium))
        .foregroundColor(LegalDocumentStyle.Colors.accent)
    }
}

// MARK: - Help Resource Link

struct HelpResourceLink: View {
    let title: String
    let url: String
    let phoneNumber: String?

    init(_ title: String, url: String, phone: String? = nil) {
        self.title = title
        self.url = url
        phoneNumber = phone
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let url = URL(string: url) {
                Link(title, destination: url)
                    .font(.body.weight(.medium))
                    .foregroundColor(LegalDocumentStyle.Colors.linkColor)
            } else {
                Text(title)
                    .legalHelplineText()
            }

            if let phone = phoneNumber {
                if let phoneURL = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") {
                    Link(phone, destination: phoneURL)
                        .font(.caption)
                        .foregroundColor(LegalDocumentStyle.Colors.helplineText)
                } else {
                    Text(phone)
                        .font(.caption)
                        .foregroundColor(LegalDocumentStyle.Colors.helplineText)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Important Disclaimer Box

struct ImportantDisclaimerBox: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.bold())
                .foregroundColor(LegalDocumentStyle.Colors.warningText)

            Text(content)
                .font(.body)
                .foregroundColor(LegalDocumentStyle.Colors.text)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LegalDocumentStyle.Colors.warningText.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LegalDocumentStyle.Colors.warningText.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.vertical, 8)
    }
}

// MARK: - Section Divider

struct LegalSectionDivider: View {
    var body: some View {
        Divider()
            .background(LegalDocumentStyle.Colors.secondaryText.opacity(0.3))
            .padding(.vertical, LegalDocumentStyle.Spacing.paragraphSpacing)
    }
}
