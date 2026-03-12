import SwiftUI

struct FriendCircleView: View {
    let name: String
    let size: CGFloat
    let color: Color
    let hasUnwatchedAnyo: Bool
    let onTap: () -> Void
    var showNameOnDrag: Bool = true
    var isJiggleMode: Bool = false
    var onDelete: (() -> Void)?

    @State private var showName = false
    @State private var hideTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 6) {
            circleContent
            nameLabel
        }
        // Reserve a fixed height so the grid doesn't shift when the label appears
        .frame(height: size + (showNameOnDrag ? 22 : 0))
    }

    // MARK: - Circle

    private var circleContent: some View {
        ZStack {
            // ── Avatar ────────────────────────────────────────────────
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            // First letter
            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.white)

            // ── Unread ring ───────────────────────────────────────────
            if hasUnwatchedAnyo {
                Circle()
                    .strokeBorder(Color.anyoBlue, lineWidth: 3)
                    .frame(width: size, height: size)
            } else {
                Circle()
                    .strokeBorder(Color(white: 0.85), lineWidth: 0.5)
                    .frame(width: size, height: size)
            }
        }
        // ── Play badge (bottom-right) ─────────────────────────────────
        .overlay(alignment: .bottomTrailing) {
            if hasUnwatchedAnyo && !isJiggleMode {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                    Image(systemName: "play.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.anyoBlue)
                        .offset(x: 1)
                }
                .offset(x: 2, y: 2)
            }
        }
        // ── Delete badge (top-left, jiggle mode only) ────────────────
        .overlay(alignment: .topLeading) {
            if isJiggleMode {
                Button {
                    onDelete?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(white: 0.35))
                }
                .offset(x: -4, y: -4)
            }
        }
        // ── Gestures ──────────────────────────────────────────────────
        .onTapGesture {
            if !isJiggleMode { onTap() }
        }
        .simultaneousGesture(dragGesture)
    }

    // MARK: - Name label

    @ViewBuilder
    private var nameLabel: some View {
        if showNameOnDrag {
            Text(name)
                .font(.caption)
                .foregroundStyle(Color.anyoText)
                .lineLimit(1)
                .opacity(showName ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: showName)
        }
    }

    // MARK: - Drag gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                guard showNameOnDrag, !isJiggleMode else { return }
                // Reveal name once the finger has moved ~20pt downward
                if value.translation.height > 20, !showName {
                    hideTask?.cancel()
                    showName = true
                }
            }
            .onEnded { _ in
                guard showNameOnDrag, showName, !isJiggleMode else { return }
                // Fade out after 1.5 seconds
                hideTask?.cancel()
                hideTask = Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    guard !Task.isCancelled else { return }
                    showName = false
                }
            }
    }
}

#Preview {
    HStack(spacing: 24) {
        FriendCircleView(
            name: "Sofia Reyes",
            size: 100,
            color: Color(red: 255/255, green: 179/255, blue: 186/255),
            hasUnwatchedAnyo: true,
            onTap: {}
        )
        FriendCircleView(
            name: "Luca Ferraro",
            size: 100,
            color: Color(red: 255/255, green: 255/255, blue: 179/255),
            hasUnwatchedAnyo: false,
            onTap: {},
            isJiggleMode: true,
            onDelete: {}
        )
    }
    .padding()
}
