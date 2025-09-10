import SwiftUI

// MARK: - EnhancedTradeCalculatorView

struct EnhancedTradeCalculatorView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Trade Calculator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Coming Soon")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Trades")
        }
    }
}

// MARK: - EnhancedTradeCalculatorView_Previews

struct EnhancedTradeCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedTradeCalculatorView()
    }
}
