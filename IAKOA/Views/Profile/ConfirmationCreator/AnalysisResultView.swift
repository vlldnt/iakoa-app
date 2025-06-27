import SwiftUI

struct AnalysisResultView: View {
    let result: String
    let enteredSiren: String

    @State private var companyName: String?
    @State private var companyAddress: String?
    @State private var showConfirmation = false
    @State private var apiKey: String = "e2a38469-7358-4b8f-a384-697358db8f26"

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

                if companyName == nil {
                    ProgressView("Chargement des infos d’entreprise...")
                        .task {
                            let info = await CreatorConfirmationFunctions.fetchCompanyInfo(siren: enteredSiren, apiKey: apiKey)
                            companyName = info.denomination
                            companyAddress = info.address
                            showConfirmation = true
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
