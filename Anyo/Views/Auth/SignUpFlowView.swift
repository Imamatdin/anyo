import SwiftUI

/// Root container for the 5-step sign-up flow.
/// Owns form state so values survive back-navigation.
struct SignUpFlowView: View {

    @State private var currentStep  = 0
    @State private var goingForward = true

    // Shared form state — passed as bindings into each step
    @State private var phoneNumber = ""
    @State private var username    = ""
    @State private var password    = ""

    var body: some View {
        ZStack(alignment: .topLeading) {

            // ── Step content ──────────────────────────────────────────────
            Group {
                switch currentStep {
                case 0:  WelcomeView(onGetStarted: advance)
                case 1:  PhoneNumberView(phoneNumber: $phoneNumber, onNext: advance)
                case 2:  UsernameView(username: $username, onNext: advance)
                case 3:  ProfilePictureView(onNext: advance)
                default: PasswordView(password: $password)
                }
            }
            .transition(slideTransition)
            .id(currentStep)

            // ── Back button (steps 1–3) ───────────────────────────────────
            if currentStep > 0 {
                Button(action: retreat) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.anyoText)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(.top, 8)
                .padding(.leading, 16)
            }
        }
    }

    // MARK: - Navigation

    private func advance() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            goingForward = true
            currentStep  = min(currentStep + 1, 4)
        }
    }

    private func retreat() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            goingForward = false
            currentStep  = max(currentStep - 1, 0)
        }
    }

    // MARK: - Transition

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: goingForward ? .trailing : .leading),
            removal:   .move(edge: goingForward ? .leading  : .trailing)
        )
    }
}

#Preview {
    SignUpFlowView()
}
