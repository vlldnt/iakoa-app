import SwiftUI

struct AuthView: View {
    
    // Enum to switch between Login and Signup tabs
    enum AuthTab {
        case login
        case signup
    }
    @State private var selectedTab: AuthTab = .login
    @Binding var isLoggedIn: Bool

    var body: some View {
        // Main vertical stack containing the entire authentication UI
        VStack(spacing: 32) {
            
            // App logo
            Image("logo-iakoa")
                .resizable()
                .renderingMode(.template)
                .frame(width: 280, height: 80)
                .foregroundStyle(Color.blueIakoa)
                .padding(.bottom, 9)

            // ZStack for the animated background behind the tab buttons
            ZStack {
                GeometryReader { geo in
                    let width = geo.size.width / 2
                    
                    // Animated background that moves based on selected tab
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.blueIakoa)
                        .frame(width: width, height: geo.size.height)
                        .offset(x: selectedTab == .login ? 0 : width)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }

                // Horizontal stack for the login and signup tab buttons
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

            // ZStack to display either the login or signup view based on the selected tab
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
        }
        .padding(15)
        .padding(.top, 30)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
        .ignoresSafeArea(.keyboard)
    }
}
