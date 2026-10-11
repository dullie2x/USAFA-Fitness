import SwiftUI

struct SplashPage: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.85
    @State private var titleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color.usafaNavy
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo
                Image("applogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // Title
                VStack(spacing: 6) {
                    Text("USAFA FITNESS")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.white)

                    Rectangle()
                        .fill(Color.usafaGold)
                        .frame(width: 36, height: 2)
                }
                .opacity(titleOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                logoOpacity = 1.0
                logoScale   = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                titleOpacity = 1.0
            }
        }
    }
}

struct SplashPage_Previews: PreviewProvider {
    static var previews: some View {
        SplashPage()
    }
}
