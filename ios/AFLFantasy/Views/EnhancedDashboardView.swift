//
//  EnhancedDashboardView.swift
//  AFLFantasy
//
//  Simple placeholder to avoid build errors
//

import SwiftUI

struct EnhancedDashboardView: View {
    var body: some View {
        VStack {
            Text("🏆 Enhanced Dashboard")
                .font(.title2)
                .fontWeight(.bold)
                .padding()

            Text("Coming Soon")
                .foregroundColor(.secondary)

            Spacer()
        }
        .navigationTitle("🏆 Dashboard")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    EnhancedDashboardView()
}
