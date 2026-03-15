import SwiftUI
import PhotosUI

struct ProfilePictureView: View {

    let onNext: () -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showPicker = false

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
            Text("Add a profile picture")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.anyoText)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            // ── Avatar placeholder / selected image ─────────────────────
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(white: 0.93))
                            .frame(width: 150, height: 150)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color(white: 0.55))
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 40)
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }

            // ── Hint ──────────────────────────────────────────────────────
            Text("This is what your friends will see")
                .font(.subheadline)
                .foregroundStyle(Color(white: 0.55))
                .padding(.top, 14)

            Spacer()

            // ── Add Photo / Continue button ─────────────────────────────
            if selectedImage != nil {
                Button(action: onNext) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.anyoBlue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Add Photo")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.anyoBlue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
            }

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
