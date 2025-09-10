import SwiftUI

// MARK: - DSCard

struct DSCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#if DEBUG
struct DSCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DSCard {
                Text("Card Content")
                    .font(.headline)
            }
            
            DSCard(padding: 24) {
                VStack {
                    Text("Custom Padding Card")
                        .font(.title3)
                    Text("With more content")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
#endif
