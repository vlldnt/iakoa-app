import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateEventView: View {
    
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventAddress: String = ""
    @State private var eventPrice: String = ""
    @State private var eventDescription: String = ""
    
    var body: some View {
        VStack(spacing: 3) {
            
            Image("logo-iakoa")
                .resizable()
                .frame(width: 190, height: 54)
                .foregroundStyle(Color(hex: "#2397FF"))
                .padding(.bottom, 25)
            
            Text("Nom")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)
            TextField("Nom de l'évènement", text: $eventName)
                .keyboardType(.default)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: "#2397FF").opacity(0.1)))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .padding(.bottom, 10)
            
            Text("Adresse")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)
            TextField("Adresse", text: $eventName)
                .keyboardType(.default)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1)))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .padding(.bottom, 10)
            
            HStack {
                Text("Date et heure")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.leading, 9)
                Spacer()
                DatePicker("", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "fr_FR"))
                
            }
            .padding(.bottom, 10)
            
            
            Text("Description de votre évènement")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)
            TextEditor(text: $eventDescription)
                .keyboardType(.default)
                .frame(height: 150)
                .padding(8)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.bottom, 10)
            
            HStack {
                Text("Prix")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 60, alignment: .leading)
                    .padding(.leading, 9)
                
                TextField("Prix en €", text: $eventPrice)
                    .keyboardType(.default)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red.opacity(0.1)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .padding(.trailing, 190)
            }
            .padding(.bottom, 10)

            Text("Photos")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)

            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    ZStack {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray.opacity(0.4))
                            .padding(20)
                    }
                    .frame(width: 110, height: 80)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .clipped()
                }
            }

            Button(action: {
                // Action ici (ajout futur)
            }) {
                Label("Ajouter une photo", systemImage: "plus")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .bold()
            }
            .padding(.top, 5)        }
        .padding()
        
    }
}

#Preview {
    CreateEventView()
}
