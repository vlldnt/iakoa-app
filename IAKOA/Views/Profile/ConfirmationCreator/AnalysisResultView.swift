import SwiftUI

struct AnalysisResultView: View {
    let result: String
    let enteredSiren: String

    @State private var companyName: String?
    @State private var companyAddress: String?
    @State private var showConfirmation = false
    @State private var apiKey: String = "f6622533-ebac-4093-a225-33ebac0093e1"

    var body: some View {
        VStack(spacing: 20) {
            Text("Résultat OCR")
                .font(.title2)
                .bold()

            ScrollView {
                Text(result)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            if result.contains(formatSiren(enteredSiren)) {
                Text("✅ Le SIREN saisi correspond")
                    .foregroundColor(.green)
                    .bold()

                if companyName == nil && companyName != "❌ SIREN introuvable" {
                    ProgressView("Vérification dans le registre national...")
                        .task {
                            let info = await CreatorConfirmationFunctions.fetchCompanyInfo(siren: enteredSiren, apiKey: apiKey)
                            if let denomination = info.denomination, let address = info.address {
                                companyName = denomination
                                companyAddress = address
                                showConfirmation = true
                            } else {
                                companyName = "❌ SIREN introuvable"
                                companyAddress = nil
                                showConfirmation = false
                            }
                        }
                }

                if let companyName = companyName, let companyAddress = companyAddress, showConfirmation {
                    Divider()
                    Text("Est-ce bien votre entreprise ?")
                        .font(.headline)
                    Text(companyName)
                        .bold()
                    Text(companyAddress)
                        .foregroundColor(.secondary)

                    Button("Oui, c’est mon entreprise") {
                        showConfirmation = false
                        self.companyName = "✅ Compte créateur activé"
                        self.companyAddress = ""
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }

                if companyName == "✅ Compte créateur activé" {
                    Text(companyName ?? "")
                        .foregroundColor(.green)
                        .font(.title2)
                        .bold()
                }
                if companyName == "❌ SIREN introuvable" {
                    Text("❌ SIREN non trouvé dans le registre national.")
                        .foregroundColor(.red)
                        .bold()
                }
            } else {
                Text("❌ Le SIREN saisi ne correspond à aucun numéro détecté.")
                    .foregroundColor(.red)
                    .bold()
            }
        }
        .padding()
    }

    private func formatSiren(_ siren: String) -> String {
        let digits = siren.filter { $0.isNumber }
        var result = ""
        for (i, char) in digits.prefix(9).enumerated() {
            if i > 0 && i % 3 == 0 { result.append(" ") }
            result.append(char)
        }
        return result
    }
}
