import UIKit
import Vision

struct CreatorConfirmationFunctions {
    static func extractNumbers(from image: UIImage) async -> String {
        guard let cgImage = image.cgImage else {
            return "❌ Erreur : image invalide"
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = ["fr-FR"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return "❌ Échec de l’analyse OCR : \(error.localizedDescription)"
        }

        guard let results = request.results, !results.isEmpty else {
            return "❌ Aucun texte détecté"
        }

        var resultText = ""
        let pattern = #"\d{3} \d{3} \d{3}"#

        for observation in results {
            if let line = observation.topCandidates(1).first?.string {
                let matches = matchesForRegex(in: line, pattern: pattern)
                for match in matches {
                    if !resultText.contains(match) {
                        if !resultText.isEmpty {
                            resultText += "\n"
                        }
                        resultText += match
                    }
                }
            }
        }

        return resultText.isEmpty ? "❌ Aucun nombre au format détecté" : resultText
    }

    static func matchesForRegex(in text: String, pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)
            let matches = regex.matches(in: text, options: [], range: nsrange)
            return matches.compactMap { match in
                if let range = Range(match.range, in: text) {
                    return String(text[range])
                }
                return nil
            }
        } catch {
            return []
        }
    }

    static func fetchCompanyInfo(siren: String, apiKey: String) async -> (denomination: String?, address: String?) {
        let cleanedSiren = siren.replacingOccurrences(of: " ", with: "")
        guard let url = URL(string: "https://api.insee.fr/entreprises/sirene/V3/siren/\(cleanedSiren)") else {
            return (nil, nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return (nil, nil)
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let uniteLegale = json["uniteLegale"] as? [String: Any] {

                let denomination = uniteLegale["denominationUniteLegale"] as? String
                let adresse = uniteLegale["adresseEtablissement"] as? [String: Any]
                let voie = adresse?["libelleVoieEtablissement"] as? String ?? ""
                let codePostal = adresse?["codePostalEtablissement"] as? String ?? ""
                let commune = adresse?["libelleCommuneEtablissement"] as? String ?? ""
                let address = "\(voie), \(codePostal) \(commune)"

                return (denomination, address)
            }
        } catch {
            print("❌ API Error: \(error)")
        }
        return (nil, nil)
    }
}

