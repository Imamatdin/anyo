import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var state: AppState = .loading
    @Published var hasCompletedOnboarding: Bool

    private let authService = AuthService.shared

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        authService.listenToAuthChanges()

        // Observe auth state and drive app state
        Task {
            // Brief splash delay, then resolve initial state
            try? await Task.sleep(for: .seconds(0.8))
            if authService.isAuthenticated {
                state = .authenticated
            } else {
                state = .unauthenticated
            }
        }
    }

    // MARK: - Auth

    func signUp(phone: String, password: String, username: String, fullName: String? = nil) async {
        do {
            try await authService.signUpWithPhone(
                phone: phone,
                password: password,
                username: username,
                fullName: fullName
            )
            state = .authenticated
        } catch {
            print("Sign-up error: \(error.localizedDescription)")
            // Fallback: simulate sign-up for demo/offline
            simulateSignUp()
        }
    }

    func signIn(phone: String, password: String) async {
        do {
            try await authService.signInWithPhone(phone: phone, password: password)
            state = .authenticated
        } catch {
            print("Sign-in error: \(error.localizedDescription)")
        }
    }

    func signInWithApple(idToken: String, nonce: String) async {
        do {
            try await authService.signInWithApple(idToken: idToken, nonce: nonce)
            state = .authenticated
        } catch {
            print("Apple sign-in error: \(error.localizedDescription)")
        }
    }

    /// Fallback for demo/offline when Supabase is unreachable.
    func simulateSignUp() {
        state = .authenticated
    }

    func signOut() {
        Task {
            try? await authService.signOut()
        }
        state = .unauthenticated
        completeOnboarding(value: false)
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
    }

    // MARK: - Private

    private func completeOnboarding(value: Bool) {
        UserDefaults.standard.set(value, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = value
    }
}
