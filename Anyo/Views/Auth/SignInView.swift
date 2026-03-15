import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var phoneNumber = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field { case phone, password }

    private var digitsOnly: String {
        phoneNumber.filter(\.isNumber)
    }

    private var isValid: Bool {
        digitsOnly.count == 10 && password.count >= 8
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Mascot ──────────────────────────────────────────────
                Image("AnyoLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(.top, 40)

                Text("Welcome back!")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.anyoText)
                    .padding(.top, 24)

                // ── Phone field ─────────────────────────────────────────
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text("+1")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.anyoText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 15)
                    .background(Color.anyoField)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    TextField("(555) 555-5555", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.anyoText)
                        .focused($focusedField, equals: .phone)
                        .onChange(of: phoneNumber) { _, new in
                            let digits = String(new.filter(\.isNumber).prefix(10))
                            let formatted = formatPhone(digits)
                            if phoneNumber != formatted { phoneNumber = formatted }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 15)
                        .background(Color.anyoField)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)

                // ── Password field ──────────────────────────────────────
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.anyoText)
                    .focused($focusedField, equals: .password)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(Color.anyoField)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 32)
                    .padding(.top, 16)

                Spacer()

                // ── Sign In button ──────────────────────────────────────
                Button {
                    let fullPhone = "+1\(digitsOnly)"
                    Task {
                        await appViewModel.signIn(phone: fullPhone, password: password)
                    }
                } label: {
                    Text("Sign In")
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
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.anyoText)
                }
            }
            .onAppear { focusedField = .phone }
        }
    }

    // MARK: - Phone formatting

    private func formatPhone(_ digits: String) -> String {
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
    SignInView()
        .environmentObject(AppViewModel())
}
