import SwiftUI

struct UsernameView: View {

    @Binding var username: String
    let onNext: () -> Void

    @FocusState private var focused: Bool

    private var isValid: Bool {
        username.count >= 3 &&
        username.range(of: "^[a-zA-Z0-9_]+$", options: .regularExpression) != nil
    }

    private var showHint: Bool { !username.isEmpty && !isValid }

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
            Text("Nice!\nNow add a username.")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.anyoText)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            // ── @ prefix field ────────────────────────────────────────────
            HStack(spacing: 0) {
                Text("@")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.anyoText.opacity(0.38))
                    .padding(.leading, 16)

                TextField("username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.username)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.anyoText)
                    .focused($focused)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 15)
            }
            .background(Color.anyoField)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 32)
            .padding(.top, 32)

            // ── Inline hint ───────────────────────────────────────────────
            if showHint {
                Text("Min 3 characters — letters, numbers, and _ only")
                    .font(.caption)
                    .foregroundStyle(Color.red.opacity(0.65))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()

            // ── Next button ───────────────────────────────────────────────
            Button(action: onNext) {
                Text("Next")
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
        .animation(.easeInOut(duration: 0.18), value: showHint)
        .onAppear { focused = true }
    }
}

#Preview {
    UsernameView(username: .constant(""), onNext: {})
}
