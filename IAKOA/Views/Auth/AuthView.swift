import SwiftUI
import FirebaseAuth
import Firebase

struct AuthView: View {
    enum AuthTab { case login, signup }
    @State private var selectedTab: AuthTab = .login
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 32) {
            Image("logo-iakoa")
                .resizable()
                .renderingMode(.template)
                .frame(width: 280, height: 80)
                .foregroundStyle(Color.blueIakoa)
                .padding(.bottom, 9)

            ZStack {
                GeometryReader { geo in
                    let width = geo.size.width / 2
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.blueIakoa)
                        .frame(width: width, height: geo.size.height)
                        .offset(x: selectedTab == .login ? 0 : width)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }

                HStack(spacing: 0) {
                    TabButton(title: "Se connecter", isSelected: selectedTab == .login) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .login
                        }
                    }
                    TabButton(title: "Créer un compte", isSelected: selectedTab == .signup) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .signup
                        }
                    }
                }
            }
            .frame(height: 44)
            .clipShape(Capsule())
            .padding(.horizontal, 4)
            .background(Color.gray.opacity(0.2))
            .clipShape(Capsule())

            ZStack {
                if selectedTab == .login {
                    LoginView(isLoggedIn: $isLoggedIn)
                        .transition(.opacity)
                } else {
                    SignInView(isLoggedIn: $isLoggedIn)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedTab)

            Spacer()
        }
        .padding(15)
        .padding(.top, 30)
    }

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
}

#Preview {
    AuthView(isLoggedIn: .constant(false)
)}
