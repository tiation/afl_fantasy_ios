//
//  SharedUIComponents.swift
//  AFL Fantasy Intelligence Platform
//
//  Centralized UI components used across the app
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - MetricCard

public struct SharedMetricCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let trend: MetricTrend?
    let icon: String?
    
    public enum MetricTrend {
        case positive, negative, neutral
        
        var color: Color {
            switch self {
            case .positive: return .green
            case .negative: return .red
            case .neutral: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .positive: return "arrow.up.circle.fill"
            case .negative: return "arrow.down.circle.fill"
            case .neutral: return "minus.circle.fill"
            }
        }
    }
    
    public init(title: String, value: String, subtitle: String? = nil, trend: MetricTrend? = nil, icon: String? = nil) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.trend = trend
        self.icon = icon
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.caption)
                        .foregroundColor(trend.color)
                }
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - StatCard

public struct SharedStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    public init(title: String, value: String, color: Color) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    public var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - ConfidenceIndicator

public struct SharedConfidenceIndicator: View {
    let confidence: Double
    let label: String?
    
    public init(confidence: Double, label: String? = "Confidence") {
        self.confidence = confidence
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                HStack {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%%", confidence * 100))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                }
            }
            
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * CGFloat(confidence), height: 8),
                        alignment: .leading
                    )
            }
            .frame(height: 8)
        }
    }
}
