import SwiftUI
import AuthenticationServices

struct WelcomeView: View {

    let onGetStarted: () -> Void

    var body: some View {
        ZStack {
            // Gradient — light blue top fades to white
            LinearGradient(
                colors: [Color.anyoPastel, .white],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.58)
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Logo wordmark ─────────────────────────────────────────
                Text("anyo")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.anyoText)
                    .padding(.top, 56)

                Spacer()

                // ── Mascot (large) ────────────────────────────────────────
                Image("AnyoLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

                // ── Tagline ───────────────────────────────────────────────
                Text("Hi! I'm Anyo!\nUse this to quickly video message anyone")
                    .font(.body)
                    .foregroundStyle(Color.anyoText.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 20)
                    .padding(.horizontal, 48)

                Spacer()

                // ── Primary CTA ───────────────────────────────────────────
                Button(action: onGetStarted) {
                    Text("Let's Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.anyoBlue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)

                // ── Sign-in link ──────────────────────────────────────────
                Button(action: { print("Sign in tapped") }) {
                    (Text("Already an Anyo?  ")
                        .foregroundStyle(Color.anyoText.opacity(0.55))
                    + Text("Sign In")
                        .foregroundStyle(Color.anyoBlue))
                        .font(.system(size: 15))
                }
                .padding(.top, 14)

                // ── Divider ───────────────────────────────────────────────
                HStack(spacing: 12) {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(Color.anyoText.opacity(0.18))
                    Text("or")
                        .font(.caption)
                        .foregroundStyle(Color.anyoText.opacity(0.35))
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(Color.anyoText.opacity(0.18))
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)

                // ── Sign in with Apple ────────────────────────────────────
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    print("Apple sign-in result: \(result)")
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    WelcomeView(onGetStarted: {})
}
