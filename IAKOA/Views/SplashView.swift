import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 1.0

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color.blueIakoa.ignoresSafeArea()

                Image("logo-iakoa")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 57)
                    .opacity(opacity)
                    .accessibilityIdentifier("SplashLogo")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeOut(duration: 1.0)) {
                                self.opacity = 0.0
                            }
                        }
                    }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
