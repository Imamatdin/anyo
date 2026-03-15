import SwiftUI

struct PhoneNumberView: View {

    @Binding var phoneNumber: String
    let onNext: () -> Void

    @FocusState private var focused: Bool

    private var isValid: Bool {
        phoneNumber.filter(\.isNumber).count == 10
    }

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
            Text("What's your\nphone number?")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.anyoText)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            // ── Input row ─────────────────────────────────────────────────
            HStack(spacing: 8) {

                // Country code (static for now)
                HStack(spacing: 6) {
                    Text("🇺🇸")
                    Text("+1")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.anyoText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 15)
                .background(Color.anyoField)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Phone field
                TextField("(555) 555-5555", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.anyoText)
                    .focused($focused)
                    .onChange(of: phoneNumber) { _, new in
                        let digits    = String(new.filter(\.isNumber).prefix(10))
                        let formatted = format(digits)
                        if phoneNumber != formatted { phoneNumber = formatted }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 15)
                    .background(Color.anyoField)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)

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
        .onAppear { focused = true }
    }

    // MARK: - Formatting

    /// Formats up to 10 digits as a US number: (XXX) XXX-XXXX
    private func format(_ digits: String) -> String {
        switch digits.count {
        case 0:
            return ""
        case 1...3:
            return digits
        case 4...6:
            return "(\(digits.prefix(3))) \(digits.dropFirst(3))"
        default:
            let area = digits.prefix(3)
            let mid  = digits.dropFirst(3).prefix(3)
            let last = digits.dropFirst(6)
            return "(\(area)) \(mid)-\(last)"
        }
    }
}

#Preview {
    PhoneNumberView(phoneNumber: .constant(""), onNext: {})
}
