import SwiftUI

struct CashCowAnalyzerView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Cash Cow Analyzer")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Text("Advanced cash generation analysis and breakeven targets will be available in a future update.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                
                Spacer()
            }
            .navigationTitle("Cash Cows")
        }
    }
}

// MARK: - Preview

struct CashCowAnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        CashCowAnalyzerView()
    }
}
