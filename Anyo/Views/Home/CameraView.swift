import AVFoundation
import SwiftUI

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Camera View

struct CameraView: View {
    let friendName: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraService = CameraService.shared

    // Recording state
    @State private var isRecording = false
    @State private var recordingProgress: CGFloat = 0
    @State private var progressTimer: Timer?

    // Cancel zone
    @State private var dragOffset: CGFloat = 0
    @State private var inCancelZone = false

    // Flash feedback
    @State private var flashColor: Color? = nil

    // Dismiss gesture
    @State private var dismissDragOffset: CGFloat = 0

    private let maxRecordingSeconds: Double = 60
    private let cancelThreshold: CGFloat = 150

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Camera feed ──────────────────────────────────────────
                if cameraService.permissionDenied {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Camera access denied")
                            .foregroundStyle(.white.opacity(0.7))
                        Text("Enable in Settings → Anyo")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                } else {
                    CameraPreviewView(session: cameraService.session)
                        .ignoresSafeArea()
                }

                // ── Top overlay ──────────────────────────────────────────
                VStack(spacing: 0) {
                    topOverlay(screenWidth: geo.size.width)
                    Spacer()
                }

                // ── Cancel zone (bottom) ─────────────────────────────────
                VStack {
                    Spacer()
                    cancelZoneView
                        .opacity(isRecording ? 1 : 0)
                        .padding(.bottom, 60)
                }

                // ── Flash overlay ────────────────────────────────────────
                if let color = flashColor {
                    color.ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .gesture(combinedGesture(screenHeight: geo.size.height))
            .simultaneousGesture(dismissSwipeGesture)
        }
        .statusBarHidden()
        .onAppear { cameraService.startSession() }
        .onDisappear {
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }

    // MARK: - Top Overlay

    private func topOverlay(screenWidth: CGFloat) -> some View {
        VStack(spacing: 8) {
            Text(friendName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                .padding(.top, 60)

            // Progress bar
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 3)

                Rectangle()
                    .fill(Color.anyoBlue)
                    .frame(width: screenWidth * recordingProgress, height: 3)
                    .animation(.linear(duration: 0.1), value: recordingProgress)
            }
            .opacity(isRecording ? 1 : 0)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Cancel Zone

    private var cancelZoneView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(inCancelZone ? Color.red : Color.red.opacity(0.6))
                    .frame(
                        width: inCancelZone ? 70 : 60,
                        height: inCancelZone ? 70 : 60
                    )
                    .animation(.easeInOut(duration: 0.15), value: inCancelZone)

                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Cancel")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(inCancelZone ? .red : Color.red.opacity(0.6))
        }
    }

    // MARK: - Hold + Drag Gesture (record)

    private func combinedGesture(screenHeight: CGFloat) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    if !isRecording {
                        startRecording()
                    }
                    let dy = drag?.translation.height ?? 0
                    dragOffset = max(0, dy)
                    inCancelZone = dragOffset > cancelThreshold
                default:
                    break
                }
            }
            .onEnded { value in
                guard isRecording else { return }

                if inCancelZone {
                    cancelRecording()
                } else {
                    sendRecording()
                }
            }
    }

    // MARK: - Dismiss Swipe Gesture

    private var dismissSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                guard !isRecording else { return }
                // Quick swipe down to dismiss
                if value.translation.height > 100,
                   value.predictedEndTranslation.height > 200 {
                    dismiss()
                }
            }
    }

    // MARK: - Recording Actions

    private func startRecording() {
        isRecording = true
        recordingProgress = 0
        dragOffset = 0
        inCancelZone = false

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // Timer that updates progress every 0.1s
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                recordingProgress += CGFloat(0.1 / maxRecordingSeconds)
                if recordingProgress >= 1.0 {
                    sendRecording()
                }
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        progressTimer?.invalidate()
        progressTimer = nil
        dragOffset = 0
        inCancelZone = false
    }

    private func cancelRecording() {
        stopRecording()
        recordingProgress = 0

        // Red flash
        withAnimation(.easeIn(duration: 0.1)) { flashColor = Color.red.opacity(0.4) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.15)) { flashColor = nil }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismiss()
            }
        }
    }

    private func sendRecording() {
        stopRecording()
        recordingProgress = 0

        print("Video sent to \(friendName)")

        // Blue flash
        withAnimation(.easeIn(duration: 0.1)) { flashColor = Color.anyoBlue.opacity(0.4) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.15)) { flashColor = nil }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismiss()
            }
        }
    }
}

#Preview {
    CameraView(friendName: "Sofia Reyes")
}
