//
//  ErrorUIComponents.swift
//  AFL Fantasy Intelligence Platform
//
//  Error presentation UI components
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - ErrorBannerView

struct ErrorBannerView: View {
    @EnvironmentObject var errorService: ErrorHandlingService
    let error: UserFriendlyError

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s.value) {
            HStack(spacing: DesignSystem.Spacing.m.value) {
                Image(systemName: error.severity.icon)
                    .foregroundColor(error.severity.color)
                    .font(.title2)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                    Text(error.title)
                        .typography(.bodySecondary)
                        .foregroundColor(error.severity.color)

                    Text(error.message)
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Button {
                    errorService.dismissCurrentError()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(error.severity.color.opacity(0.6))
                }
                .tappableFrame()
            }

            if !error.suggestedActions.isEmpty {
                HStack(spacing: DesignSystem.Spacing.s.value) {
                    ForEach(error.suggestedActions.indices, id: \.self) { index in
                        let action = error.suggestedActions[index]

                        Button(action.title) {
                            action.action()
                        }
                        .buttonStyle(AFLButtonStyle(variant: index == 0 ? .primary : .secondary))
                        .font(.caption)
                    }

                    Spacer()
                }
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .fill(error.severity.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .stroke(error.severity.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - ErrorHandlingModifier

struct ErrorHandlingModifier: ViewModifier {
    @StateObject private var errorService = ErrorHandlingService.shared

    func body(content: Content) -> some View {
        content
            .environmentObject(errorService)
            .overlay(alignment: .top) {
                if errorService.isShowingErrorBanner,
                   let error = errorService.currentError
                {
                    ErrorBannerView(error: error)
                        .padding(DesignSystem.Spacing.m.value)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1000)
                }
            }
    }
}

extension View {
    func errorHandling() -> some View {
        modifier(ErrorHandlingModifier())
    }
}
