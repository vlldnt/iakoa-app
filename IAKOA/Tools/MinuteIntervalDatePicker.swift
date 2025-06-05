import SwiftUI

struct MinuteIntervalDatePicker: UIViewRepresentable {
    @Binding var selection: Date
    var minuteInterval: Int
    var displayedComponents: DatePickerComponents

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = displayedComponents == .date ? .date : .dateAndTime
        picker.minuteInterval = minuteInterval
        picker.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selection
        uiView.minuteInterval = minuteInterval
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: MinuteIntervalDatePicker
        init(_ parent: MinuteIntervalDatePicker) { self.parent = parent }
        @objc func valueChanged(_ sender: UIDatePicker) {
            parent.selection = sender.date
        }
    }
}
