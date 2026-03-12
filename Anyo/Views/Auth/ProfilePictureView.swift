import SwiftUI

struct ProfilePictureView: View {

    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            // ── Mascot (small) ────────────────────────────────────────────
            Image("AnyoLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 72)

            // ── Heading ───────────────────────────────────────────────────
            Text("Add a profile picture")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.anyoText)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            // ── Avatar placeholder ────────────────────────────────────────
            Button {
                print("Open photo picker")
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.93))
                        .frame(width: 150, height: 150)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(white: 0.55))
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 40)

            // ── Hint ──────────────────────────────────────────────────────
            Text("This is what your friends will see")
                .font(.subheadline)
                .foregroundStyle(Color(white: 0.55))
                .padding(.top, 14)

            Spacer()

            // ── Add Photo button ──────────────────────────────────────────
            Button(action: onNext) {
                Text("Add Photo")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.anyoBlue)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)

            // ── Skip link ─────────────────────────────────────────────────
            Button(action: onNext) {
                Text("Skip for now")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(white: 0.55))
            }
            .padding(.top, 12)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    ProfilePictureView(onNext: {})
}
