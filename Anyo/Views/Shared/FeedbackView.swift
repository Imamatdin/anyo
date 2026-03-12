import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""

    var body: some View {
        ZStack {
            // ── Gradient background ──────────────────────────────────
            LinearGradient(
                colors: [
                    Color(red: 255/255, green: 167/255, blue: 38/255),  // #FFA726
                    Color(red: 255/255, green: 213/255, blue: 79/255)   // #FFD54F
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // ── Header text ──────────────────────────────────
                    Text("i have a question")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color(white: 0.2))
                        .padding(.top, 50)

                    Text("tell us what we should be building!\nand we'll get to it!")
                        .font(.body)
                        .foregroundStyle(Color(white: 0.3))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    // ── Quote bubble icon ────────────────────────────
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                        .padding(.top, 32)

                    Text("I have a feature idea")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color(white: 0.2))
                        .padding(.top, 12)

                    // ── Text input ───────────────────────────────────
                    ZStack(alignment: .topLeading) {
                        if feedbackText.isEmpty {
                            Text("Tell us what we should be building")
                                .foregroundStyle(Color(white: 0.55))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }

                        TextEditor(text: $feedbackText)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(Color.anyoText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .font(.body)
                    .frame(minHeight: 120)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // ── Back button ──────────────────────────────────
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Back")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundStyle(Color.anyoBlue)
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    FeedbackView()
}
