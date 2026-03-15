import SwiftUI

// MARK: - TutorialView

struct TutorialView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var currentPage     = 0
    @State private var hasSeenLastPage = false

    var body: some View {
        TabView(selection: $currentPage) {
            TutorialPage1()
                .tag(0)
            TutorialPage2()
                .tag(1)
            TutorialPage3()
                .tag(2)
            TutorialPage4(hasSeenAll: hasSeenLastPage, onDone: complete)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
        .onChange(of: currentPage) { _, new in
            if new == 3 { hasSeenLastPage = true }
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = .white
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        }
        .onDisappear {
            UIPageControl.appearance().currentPageIndicatorTintColor = nil
            UIPageControl.appearance().pageIndicatorTintColor = nil
        }
    }

    private func complete() {
        appViewModel.completeOnboarding()
    }
}

#Preview {
    TutorialView()
        .environmentObject(AppViewModel())
}

// ══════════════════════════════════════════════════════════════
// MARK: - Pages
// ══════════════════════════════════════════════════════════════

// Page 1 ── intro (same gradient as the auth flow)
private struct TutorialPage1: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.anyoPastel, .white],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.65)
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Learn how to\nsend Anyos")
                    .font(.title.bold())
                    .foregroundStyle(Color.anyoText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 70)
                    .padding(.horizontal, 32)

                Spacer()

                // Mascot
                Image("AnyoLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

                // Play button
                ZStack {
                    Circle().fill(.white)
                    Circle().strokeBorder(Color.anyoBlue, lineWidth: 3)
                    Image(systemName: "play.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.anyoBlue)
                        .offset(x: 3) // optical centering
                }
                .frame(width: 70, height: 70)
                .shadow(color: Color.anyoBlue.opacity(0.2), radius: 10, y: 4)
                .padding(.top, 28)

                Text("Tutorial")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.anyoBlue)
                    .padding(.top, 10)

                Spacer()
            }
        }
    }
}

// Page 2 ── "Tap on a friend"
private struct TutorialPage2: View {
    var body: some View {
        TutorialSlide {
            Text("Tap on a friend")
                .slideTitle()
            Spacer()
            PhoneFrame { FriendGridScreen(highlightedIndex: 2) }
            Spacer()
        }
    }
}

// Page 3 ── "Hold to record"
private struct TutorialPage3: View {
    var body: some View {
        TutorialSlide {
            Text("Hold to record")
                .slideTitle()
            Spacer()
            PhoneFrame { CameraScreen() }
            Spacer()
        }
    }
}

// Page 4 ── "Release to send" + "Got it!" CTA
private struct TutorialPage4: View {
    let hasSeenAll: Bool
    let onDone: () -> Void

    var body: some View {
        TutorialSlide {
            Text("Release to send")
                .slideTitle()
            Spacer()
            PhoneFrame { FriendGridScreen(highlightedIndex: 2, showSent: true) }
            Spacer()
            // Button always reserves its layout space; opacity controls visibility.
            // This avoids the phone illustration jumping when the button fades in.
            Button(action: onDone) {
                Text("Got it!")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(slideBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 90) // above page dots + home indicator
            .opacity(hasSeenAll ? 1 : 0)
            .disabled(!hasSeenAll)
            .animation(.easeInOut(duration: 0.3), value: hasSeenAll)
        }
    }
}

// ══════════════════════════════════════════════════════════════
// MARK: - Shared slide helpers
// ══════════════════════════════════════════════════════════════

/// The rich blue used for tutorial slides 2–4
private let slideBg = Color(red: 2/255, green: 136/255, blue: 209/255)

/// Full-screen blue wrapper for pages 2–4
private struct TutorialSlide<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        ZStack {
            slideBg.ignoresSafeArea()
            VStack(spacing: 0) { content }
        }
    }
}

extension View {
    /// Large white bold title pinned near the top of a tutorial slide
    fileprivate func slideTitle() -> some View {
        self
            .font(.title.bold())
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.top, 70)
            .padding(.horizontal, 32)
    }
}

// ══════════════════════════════════════════════════════════════
// MARK: - Phone frame wrapper
// ══════════════════════════════════════════════════════════════

private struct PhoneFrame<Screen: View>: View {
    let screen: Screen
    init(@ViewBuilder screen: () -> Screen) { self.screen = screen() }

    var body: some View {
        ZStack {
            // Phone body
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .frame(width: 180, height: 300)

            // Phone border
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: 180, height: 300)

            // Notch
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 56, height: 8)
                .offset(y: -143)

            // Screen content clipped to rounded rect
            screen
                .frame(width: 156, height: 264)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

// ══════════════════════════════════════════════════════════════
// MARK: - Illustrations
// ══════════════════════════════════════════════════════════════

/// Homepage grid (pages 2 & 4) — circles suggest friend avatars
private struct FriendGridScreen: View {
    var highlightedIndex: Int = -1
    var showSent: Bool = false

    private let cols = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color(red: 240/255, green: 248/255, blue: 255/255)

            VStack(spacing: 0) {
                // Search bar mock
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(red: 218/255, green: 232/255, blue: 246/255))
                    .frame(height: 24)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                // Avatar grid
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(0..<4, id: \.self) { i in
                        avatarCell(i)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)

                Spacer()
            }
        }
    }

    @ViewBuilder
    private func avatarCell(_ i: Int) -> some View {
        let isActive = (i == highlightedIndex)

        ZStack(alignment: .topTrailing) {
            // Avatar circle
            Circle()
                .fill(isActive
                      ? Color.anyoBlue
                      : Color(red: 200/255, green: 218/255, blue: 238/255))
                .frame(width: 54, height: 54)
                // Tap-ripple ring — page 2 only
                .overlay(
                    (!showSent && isActive)
                        ? Circle()
                            .strokeBorder(Color.anyoBlue.opacity(0.4), lineWidth: 2.5)
                            .frame(width: 68, height: 68)
                        : nil
                )

            // Sent checkmark badge — page 4 only
            if showSent && isActive {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(Color(red: 52/255, green: 199/255, blue: 89/255))
                            .frame(width: 21, height: 21)
                    )
                    .offset(x: 7, y: -7)
            }
        }
        .frame(width: 66, height: 66)
    }
}

/// Camera-view illustration — page 3
private struct CameraScreen: View {
    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 18) {
                Spacer()

                // Viewfinder
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 28/255, green: 30/255, blue: 40/255))
                    .frame(width: 132, height: 158)
                    .overlay(
                        // Recording dot
                        Circle()
                            .fill(Color.red)
                            .frame(width: 9, height: 9)
                            .padding(10),
                        alignment: .topTrailing
                    )
                    .overlay(FocusCorners())

                // Record button (hold = white filled)
                ZStack {
                    Circle().strokeBorder(.white, lineWidth: 3).frame(width: 58, height: 58)
                    Circle().fill(.white).frame(width: 46, height: 46)
                }

                Spacer()
            }
        }
    }
}

/// Four L-shaped corner marks on the camera viewfinder
private struct FocusCorners: View {
    var body: some View {
        GeometryReader { geo in
            let (w, h) = (geo.size.width, geo.size.height)
            let len: CGFloat = 13
            let pad: CGFloat = 6
            let lw: CGFloat  = 2.5

            Path { p in
                // Top-left
                p.move(to:    CGPoint(x: pad,       y: pad + len))
                p.addLine(to: CGPoint(x: pad,       y: pad))
                p.addLine(to: CGPoint(x: pad + len, y: pad))
                // Top-right
                p.move(to:    CGPoint(x: w - pad - len, y: pad))
                p.addLine(to: CGPoint(x: w - pad,       y: pad))
                p.addLine(to: CGPoint(x: w - pad,       y: pad + len))
                // Bottom-left
                p.move(to:    CGPoint(x: pad,       y: h - pad - len))
                p.addLine(to: CGPoint(x: pad,       y: h - pad))
                p.addLine(to: CGPoint(x: pad + len, y: h - pad))
                // Bottom-right
                p.move(to:    CGPoint(x: w - pad - len, y: h - pad))
                p.addLine(to: CGPoint(x: w - pad,       y: h - pad))
                p.addLine(to: CGPoint(x: w - pad,       y: h - pad - len))
            }
            .stroke(Color.white.opacity(0.6), lineWidth: lw)
        }
    }
}
