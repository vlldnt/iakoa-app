
import SwiftUI

struct Tools {
    static func socialField(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
                .bold()
            TextField(label, text: text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}
