import SwiftUI

struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .contentShape(Rectangle())
        }
    }
