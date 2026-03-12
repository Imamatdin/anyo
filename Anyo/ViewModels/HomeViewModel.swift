import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var friends: [MockFriend] = []
    @Published var isJiggleMode: Bool = false
    @Published var reminders: [UUID: String] = [:]

    private let friendService = FriendService.shared

    var friendCount: Int { friends.count }

    init() {
        friends = MockData.friends
        loadRealFriends()
    }

    // MARK: - Supabase fetch

    private func loadRealFriends() {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        Task {
            do {
                let realFriends = try await friendService.fetchFriends(for: userId)
                let mapped = realFriends.map { f in
                    MockFriend(
                        id: f.profile.id,
                        name: f.profile.fullName ?? f.profile.username,
                        username: f.profile.username,
                        hasUnwatchedAnyo: false,
                        lastStatus: "",
                        lastStatusTime: "",
                        isFavorite: f.isFavorite,
                        gridPosition: f.gridPosition ?? 0,
                        color: Self.colorForUsername(f.profile.username)
                    )
                }
                if !mapped.isEmpty {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        friends = mapped
                    }
                }
                // else keep MockData fallback
            } catch {
                print("Failed to fetch friends, using mock data: \(error.localizedDescription)")
                // Keep MockData — app still works offline
            }
        }
    }

    /// Deterministic pastel color from a username string.
    private static func colorForUsername(_ username: String) -> Color {
        let hash = username.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let pastels: [Color] = [
            Color(red: 255/255, green: 179/255, blue: 186/255),
            Color(red: 179/255, green: 217/255, blue: 255/255),
            Color(red: 204/255, green: 255/255, blue: 204/255),
            Color(red: 255/255, green: 236/255, blue: 179/255),
            Color(red: 229/255, green: 204/255, blue: 255/255),
            Color(red: 255/255, green: 218/255, blue: 185/255),
            Color(red: 179/255, green: 255/255, blue: 242/255),
            Color(red: 255/255, green: 255/255, blue: 179/255),
        ]
        return pastels[hash % pastels.count]
    }

    // MARK: - Jiggle mode

    func enterJiggleMode() {
        isJiggleMode = true
    }

    func exitJiggleMode() {
        isJiggleMode = false
    }

    func removeFriend(id: UUID) {
        withAnimation(.easeInOut(duration: 0.25)) {
            friends.removeAll { $0.id == id }
        }
    }

    func toggleFavorite(id: UUID) {
        guard let index = friends.firstIndex(where: { $0.id == id }) else { return }
        friends[index].isFavorite.toggle()
    }

    func addFriend(_ friend: MockFriend) {
        withAnimation(.easeInOut(duration: 0.25)) {
            friends.append(friend)
        }
    }

    // MARK: - Layout

    /// Diameter of each friend circle, scaled to the available width.
    func circleSize(for count: Int, in availableWidth: CGFloat) -> CGFloat {
        let ratio: CGFloat = switch count {
        case 1:       0.55
        case 2:       0.42
        case 3...4:   0.38
        case 5...6:   0.32
        case 7...9:   0.28
        case 10...12: 0.23
        default:      0.21
        }
        return availableWidth * ratio
    }
}
