import SwiftUI

struct PasswordView: View {

    @Binding var password: String
    @State  private var showPassword = false
    @FocusState private var focused: Bool
    @EnvironmentObject private var appViewModel: AppViewModel

    private var isValid: Bool { password.count >= 8 }

    var body: some View {
        VStack(spacing: 0) {

            // ── Mascot (small) ────────────────────────────────────────────
            Image("AnyoLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, 72)

            // ── Heading ───────────────────────────────────────────────────
            Text("Great!\nAdd a password.")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.anyoText)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            // ── Password field ────────────────────────────────────────────
            HStack(spacing: 8) {
                Group {
                    if showPassword {
                        TextField("Min 8 characters", text: $password)
                    } else {
                        SecureField("Min 8 characters", text: $password)
                    }
                }
                .textContentType(.newPassword)
                .font(.system(size: 17))
                .foregroundStyle(Color.anyoText)
                .focused($focused)

                Button {
                    showPassword.toggle()
                    focused = true
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundStyle(Color.anyoText.opacity(0.35))
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.anyoField)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 32)
            .padding(.top, 32)

            // ── Inline feedback ───────────────────────────────────────────
            if !password.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    if isValid {
                        Text("Looks good!")
                    } else {
                        let remaining = 8 - password.count
                        Text("\(remaining) more character\(remaining == 1 ? "" : "s") needed")
                    }
                }
                .font(.caption)
                .foregroundStyle(isValid ? Color.anyoBlue : Color.red.opacity(0.65))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()

            // ── Create Account button ─────────────────────────────────────
            Button {
                appViewModel.simulateSignUp()
            } label: {
                Text("Create Account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isValid ? Color.anyoBlue : Color.anyoBlue.opacity(0.3))
                    .clipShape(Capsule())
            }
            .disabled(!isValid)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.18), value: !password.isEmpty)
        .onAppear { focused = true }
    }
}

#Preview {
    PasswordView(password: .constant(""))
        .environmentObject(AppViewModel())
}
