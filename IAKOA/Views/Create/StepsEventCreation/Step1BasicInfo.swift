import SwiftUI

struct Step1BasicInfo: View {
    
    @Binding var eventName: String
    @Binding var eventDescription: String
    @Binding var eventCategories: [String]

    var body: some View {
        VStack(spacing: 5) {
            Form {
                Section(header: Text("Nom de l'événement")) {
                    ZStack(alignment: .trailing) {
                        TextField("Nom (70 caractères maximum)", text: $eventName)
                            .onChange(of: eventName) { _, newValue in
                                if newValue.count > 70 {
                                    eventName = String(newValue.prefix(70))
                                }
                            }
                            .font(.system(size: 14))
                            .padding(.trailing, 40)

                        Text("\(eventName.count)/60")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }

                Section(header: Text("Description")) {
                    TextEditor(text: $eventDescription)
                        .frame(minHeight: 180)
                        .font(.system(size: 14))
                }

                Section(header: Text("Catégories sélectionnées")) {
                    WrapHStack(data: eventCategories, spacing: 8) { category in
                        let colorHex = EventCategories.dict[category]?.color ?? "#999999"
                        let color = Color(hex: colorHex)

                        HStack(spacing: 10) {
                            Image(systemName: EventCategories.dict[category]?.icon ?? "questionmark")
                                .font(.system(size: 16))
                                .foregroundColor(color)

                            Text(EventCategories.dict[category]?.label ?? category)
                                .font(.system(size: 14))
                                .foregroundColor(color)

                            Button(action: {
                                hideKeyboard()
                                eventCategories.removeAll { $0 == category }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(color)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(color.opacity(0.2))
                        .cornerRadius(12)
                    }
                }

                Section(header: Text("Ajouter une catégorie")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(EventCategories.dict.sorted(by: { $0.value.label < $1.value.label }), id: \.key) { key, data in
                                let isSelected = eventCategories.contains(key)
                                Button(action: {
                                    hideKeyboard()
                                    if !isSelected && eventCategories.count < 4 {
                                        eventCategories.append(key)
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: data.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(isSelected ? Color.gray : Color(hex: data.color))
                                        
                                        Text(data.label)
                                            .font(.system(size: 14))
                                            .foregroundColor(isSelected ? Color.gray : Color(hex: data.color))
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(isSelected ? Color.gray.opacity(0.2) : Color(hex: data.color).opacity(0.2))
                                    .cornerRadius(12)
                                }
                                .disabled(isSelected || eventCategories.count >= 4)
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}
