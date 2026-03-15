import SwiftUI

@main
struct AnyoApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            AppRouterView()
                .environmentObject(appViewModel)
        }
    }
}
