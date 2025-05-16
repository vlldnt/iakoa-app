import SwiftUI

struct CategoryButton: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .padding()
                .background(color.opacity(0.25))
                .foregroundColor(color)
                .clipShape(Circle())
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
                .bold()
        }
    }
}
