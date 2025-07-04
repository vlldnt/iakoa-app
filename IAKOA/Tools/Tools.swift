import SwiftUI
import Foundation
import CoreLocation

/// Extension to initialize a Color from a hex string
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    static let blueIakoa = Color(hex: "#2397FF")
}

/// Extension to calculate the height of a string with a constrained width and font
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

/// UIViewRepresentable to provide a zoomable scroll view for SwiftUI content
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostedView = UIHostingController(rootView: content).view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .clear
        
        scrollView.addSubview(hostedView)
        
        /// Attach hostedView to scrollView edges without forcing width/height
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
        ])
        
        context.coordinator.hostedView = hostedView
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        /// No specific update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    /// Coordinator to handle zooming
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostedView: UIView?
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostedView
        }
    }
}

/// Extension to check if a date is in the past or in the future/today
extension Date {
    var isInPast: Bool {
        self < Calendar.current.startOfDay(for: Date())
    }

    var isInFutureOrToday: Bool {
        !isInPast
    }
}

/// Utility struct to format a list of dates as a string
struct DateUtils {
    static func formattedDates(_ dates: [Date]) -> String {
        let sorted = dates.sorted()
        guard !sorted.isEmpty else { return "" }

        let formatterFull = DateFormatter()
        formatterFull.locale = Locale(identifier: "fr_FR")
        formatterFull.dateFormat = "dd/MM/yyyy"

        let formatterShort = DateFormatter()
        formatterShort.locale = Locale(identifier: "fr_FR")
        formatterShort.dateFormat = "dd/MM"

        if sorted.count == 1 {
            return formatterFull.string(from: sorted[0])
        } else {
            let first = sorted.first!
            let last = sorted.last!

            let sameYear = Calendar.current.component(.year, from: first) == Calendar.current.component(.year, from: last)

            if sameYear {
                return "du \(formatterShort.string(from: first)) au \(formatterFull.string(from: last))"
            } else {
                return "du \(formatterFull.string(from: first)) au \(formatterFull.string(from: last))"
            }
        }
    }
}

/// Utility struct to get the status of an event from its dates
struct EventStatusUtils {
    static func eventStatus(from dates: [Date]) -> String {
        let now = Date()
        let sortedDates = dates.sorted()
        guard let start = sortedDates.first else { return "" }
        guard let end = sortedDates.last else { return "" }

        if start < now {
            if end > now {
                let daysRemaining = Calendar.current.dateComponents([.day], from: now, to: end).day ?? 0
                let jours = daysRemaining == 1 ? "1 jour restant" : "\(daysRemaining) jours restants"
                return "(En cours, \(jours))"
            } else {
                return "(Évènement passé)"
            }
        }

        let daysRemaining = Calendar.current.dateComponents([.day], from: now, to: start).day ?? 0
        if daysRemaining == 0 {
            return "(Aujourd'hui)"
        } else if daysRemaining == 1 {
            return "(Demain)"
        }

        let months = daysRemaining / 30
        let weeks = (daysRemaining % 30) / 7
        let days = (daysRemaining % 30) % 7

        var parts: [String] = []
        if months > 0 { parts.append("\(months) mois") }
        if weeks > 0 { parts.append("\(weeks) semaine\(weeks > 1 ? "s" : "")") }
        if days > 0 { parts.append("\(days) jour\(days > 1 ? "s" : "")") }

        return "(dans \(parts.joined(separator: ", ")))"
    }
}

/// SwiftUI view to display a full screen image with zoom and tap to dismiss
struct FullScreenImageView: View {
    let imageURL: URL
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            dismiss()
                        }
                case .failure:
                    Image(systemName: "xmark.octagon")
                        .foregroundColor(.white)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

/// Extension to hide the keyboard from any SwiftUI view
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Function to compare two optional CLLocationCoordinate2D for equality
func coordinatesEqual(_ lhs: CLLocationCoordinate2D?, _ rhs: CLLocationCoordinate2D?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil): return true
    case let (l?, r?): return l.latitude == r.latitude && l.longitude == r.longitude
    default: return false
    }
}
