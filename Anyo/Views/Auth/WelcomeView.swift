import SwiftUI
import AuthenticationServices
import CryptoKit

struct WelcomeView: View {

    let onGetStarted: () -> Void

    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showSignIn = false
    @State private var currentNonce: String?

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
                Button(action: { showSignIn = true }) {
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
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                              let tokenData = credential.identityToken,
                              let idToken = String(data: tokenData, encoding: .utf8),
                              let nonce = currentNonce else {
                            print("Apple sign-in: missing token or nonce")
                            return
                        }
                        Task {
                            await appViewModel.signInWithApple(idToken: idToken, nonce: nonce)
                        }
                    case .failure(let error):
                        print("Apple sign-in error: \(error.localizedDescription)")
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environmentObject(appViewModel)
        }
    }

    // MARK: - Nonce helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    WelcomeView(onGetStarted: {})
        .environmentObject(AppViewModel())
}
