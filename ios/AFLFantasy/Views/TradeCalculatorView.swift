//
//  TradeCalculatorView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - EnhancedTradeCalculatorView

struct EnhancedTradeCalculatorView: View {
    @State private var selectedPlayerIn: EnhancedPlayer?
    @State private var selectedPlayerOut: EnhancedPlayer?

    // Native iOS Haptic Feedback
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🔄 Trade Calculator")
                        .font(.title)
                        .bold()
                        .padding()
                        .accessibilityLabel("Trade Calculator")
                        .accessibilityTraits(.header)

                    // Trade OUT section
                    VStack(alignment: .leading) {
                        Text("TRADE OUT")
                            .font(.headline)
                            .foregroundColor(.red)

                        Button("Select Player to Trade Out") {
                            selectionFeedback.selectionChanged()
                            // TODO: Show player picker
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .accessibilityLabel("Select player to trade out")
                        .accessibilityTraits(.button)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)

                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title)
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)

                    // Trade IN section
                    VStack(alignment: .leading) {
                        Text("TRADE IN")
                            .font(.headline)
                            .foregroundColor(.green)

                        Button("Select Player to Trade In") {
                            selectionFeedback.selectionChanged()
                            // TODO: Show player picker
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .accessibilityLabel("Select player to trade in")
                        .accessibilityTraits(.button)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)

                    // Trade Score
                    TradeScoreView()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("🔄 Trades")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - TradeScoreView

struct TradeScoreView: View {
    var body: some View {
        VStack {
            Text("Trade Score")
                .font(.headline)
                .accessibilityLabel("Trade Score")
                .accessibilityTraits(.header)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: 0.75)

                VStack {
                    Text("75")
                        .font(.title)
                        .bold()
                        .foregroundColor(.orange)
                    Text("Good Trade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Trade score: 75 out of 100, Good Trade")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    EnhancedTradeCalculatorView()
}
