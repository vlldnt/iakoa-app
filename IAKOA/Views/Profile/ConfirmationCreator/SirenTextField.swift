import SwiftUI

struct SirenTextField: View {
    @Binding var rawSiren: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("SIREN (9 chiffres)", text: Binding(
            get: { rawSiren },
            set: { newValue in
                // Garde uniquement les chiffres, coupe à 9 caractères en temps réel
                let digits = newValue.filter { $0.isNumber }
                rawSiren = String(digits.prefix(9))
            }
        ))
        .keyboardType(.numberPad)
        .multilineTextAlignment(.center)
        .frame(width: 170)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .focused($isFocused)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Terminer") {
                    isFocused = false
                }
            }
        }
        .onTapGesture {
            isFocused = true
        }
    }
}
