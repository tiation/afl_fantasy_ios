import SwiftUI

// MARK: - OfflineStatusView

struct OfflineStatusView: View {
    @State private var isOffline = false

    var body: some View {
        if isOffline {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.red)
                Text("Offline Mode")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - OfflineStatusView_Previews

struct OfflineStatusView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineStatusView()
    }
}
