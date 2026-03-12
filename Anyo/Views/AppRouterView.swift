import SwiftUI

// MARK: - App state machine

enum AppState {
    case loading
    case unauthenticated
    case authenticated
}

// MARK: - Root router

struct AppRouterView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            routeContent
                .id(routeId)          // forces SwiftUI to swap views on route change
                .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.3), value: routeId)
    }

    // MARK: - Route resolution

    @ViewBuilder
    private var routeContent: some View {
        switch appViewModel.state {
        case .loading:
            splashView

        case .unauthenticated:
            SignUpFlowView()

        case .authenticated:
            if appViewModel.hasCompletedOnboarding {
                HomeView()
            } else {
                TutorialView()
            }
        }
    }

    /// Unique string per visible destination — drives the crossfade animation.
    private var routeId: String {
        switch appViewModel.state {
        case .loading:        return "loading"
        case .unauthenticated: return "unauthenticated"
        case .authenticated:   return appViewModel.hasCompletedOnboarding ? "home" : "tutorial"
        }
    }

    // MARK: - Splash

    private var splashView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Image("AnyoLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

#Preview {
    AppRouterView()
        .environmentObject(AppViewModel())
}
