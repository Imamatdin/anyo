import Foundation
import Supabase
import SwiftUI

// MARK: - Models

struct Friendship: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    let friendId: UUID
    let status: String
    let gridPosition: Int?
    let isFavorite: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case friendId = "friend_id"
        case status
        case gridPosition = "grid_position"
        case isFavorite = "is_favorite"
        case createdAt = "created_at"
    }
}

struct FriendWithProfile: Identifiable, Sendable {
    let friendshipId: UUID
    let profile: Profile
    let status: String
    let gridPosition: Int?
    let isFavorite: Bool

    var id: UUID { profile.id }
}

/// Row shape returned by the joined query
private struct FriendshipRow: Codable {
    let id: UUID
    let userId: UUID
    let friendId: UUID
    let status: String
    let gridPosition: Int?
    let isFavorite: Bool
    let profiles: Profile // the joined friend profile

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case friendId = "friend_id"
        case status
        case gridPosition = "grid_position"
        case isFavorite = "is_favorite"
        case profiles
    }
}

// MARK: - Friend Service

@MainActor
final class FriendService: ObservableObject {
    static let shared = FriendService()

    private let supabase = SupabaseConfig.shared

    private init() {}

    // MARK: - Fetch Friends

    func fetchFriends(for userId: UUID) async throws -> [FriendWithProfile] {
        let rows: [FriendshipRow] = try await supabase
            .from("friendships")
            .select("*, profiles!friendships_friend_id_fkey(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "accepted")
            .execute()
            .value

        return rows.map { row in
            FriendWithProfile(
                friendshipId: row.id,
                profile: row.profiles,
                status: row.status,
                gridPosition: row.gridPosition,
                isFavorite: row.isFavorite
            )
        }
    }

    // MARK: - Send Friend Request

    func sendFriendRequest(from userId: UUID, to friendId: UUID) async throws {
        let insert = FriendshipInsert(userId: userId, friendId: friendId)

        try await supabase
            .from("friendships")
            .insert(insert)
            .execute()
    }

    // MARK: - Accept Friend Request

    func acceptFriendRequest(friendshipId: UUID) async throws {
        try await supabase
            .from("friendships")
            .update(["status": "accepted"])
            .eq("id", value: friendshipId.uuidString)
            .execute()
    }

    // MARK: - Remove Friend

    func removeFriend(friendshipId: UUID) async throws {
        try await supabase
            .from("friendships")
            .delete()
            .eq("id", value: friendshipId.uuidString)
            .execute()
    }

    // MARK: - Update Grid Position

    func updateGridPosition(friendshipId: UUID, position: Int) async throws {
        try await supabase
            .from("friendships")
            .update(["grid_position": position])
            .eq("id", value: friendshipId.uuidString)
            .execute()
    }

    // MARK: - Toggle Favorite

    func toggleFavorite(friendshipId: UUID, currentValue: Bool) async throws {
        try await supabase
            .from("friendships")
            .update(["is_favorite": !currentValue])
            .eq("id", value: friendshipId.uuidString)
            .execute()
    }

    // MARK: - Search Users

    func searchUsers(query: String) async throws -> [Profile] {
        let profiles: [Profile] = try await supabase
            .from("profiles")
            .select()
            .ilike("username", pattern: "%\(query)%")
            .limit(20)
            .execute()
            .value

        return profiles
    }
}

// MARK: - Insert helper

private struct FriendshipInsert: Encodable {
    let userId: UUID
    let friendId: UUID

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case friendId = "friend_id"
    }
}
