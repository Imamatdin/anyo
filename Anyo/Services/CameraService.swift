import AVFoundation
import SwiftUI

@MainActor
final class CameraService: ObservableObject {
    static let shared = CameraService()

    @Published var isSessionRunning = false
    @Published var permissionDenied = false

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.anyo.camera")
    private var currentPosition: AVCaptureDevice.Position = .front

    private init() {}

    // MARK: - Public

    func startSession() {
        guard !isSessionRunning else { return }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    if granted {
                        self?.configureAndStart()
                    } else {
                        self?.permissionDenied = true
                    }
                }
            }
        default:
            permissionDenied = true
        }
    }

    func switchCamera() {
        currentPosition = (currentPosition == .front) ? .back : .front
        sessionQueue.async { [weak self] in
            self?.reconfigure()
        }
    }

    // MARK: - Private

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configure()
            self.session.startRunning()
            Task { @MainActor in
                self.isSessionRunning = true
            }
        }
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // Remove existing inputs
        for input in session.inputs {
            session.removeInput(input)
        }

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentPosition
        ),
        let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        session.commitConfiguration()
    }

    private func reconfigure() {
        session.beginConfiguration()

        for input in session.inputs {
            session.removeInput(input)
        }

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentPosition
        ),
        let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        session.commitConfiguration()
    }
}
