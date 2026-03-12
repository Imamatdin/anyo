import Foundation
import Supabase
import SwiftUI

// MARK: - Profile model

struct Profile: Codable, Identifiable, Sendable {
    let id: UUID
    let username: String
    let fullName: String?
    let phoneNumber: String?
    let avatarUrl: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

// MARK: - Auth Service

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: Profile?
    @Published var isAuthenticated: Bool = false

    private let supabase = SupabaseConfig.shared

    private init() {}

    // MARK: - Sign Up

    func signUpWithPhone(phone: String, password: String, username: String, fullName: String? = nil) async throws {
        let authResponse = try await supabase.auth.signUp(
            phone: phone,
            password: password
        )

        let userId = authResponse.user.id

        let profile = ProfileInsert(
            id: userId,
            username: username,
            fullName: fullName,
            phoneNumber: phone
        )

        try await supabase
            .from("profiles")
            .insert(profile)
            .execute()

        try await fetchProfile(userId: userId)
        isAuthenticated = true
    }

    // MARK: - Sign In

    func signInWithPhone(phone: String, password: String) async throws {
        let session = try await supabase.auth.signIn(
            phone: phone,
            password: password
        )

        try await fetchProfile(userId: session.user.id)
        isAuthenticated = true
    }

    // MARK: - Sign In with Apple

    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )

        let userId = session.user.id

        // Check if profile exists, create if not
        let existing: [Profile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value

        if existing.isEmpty {
            let username = "user_\(userId.uuidString.prefix(8))"
            let profile = ProfileInsert(
                id: userId,
                username: username,
                fullName: session.user.email,
                phoneNumber: nil
            )

            try await supabase
                .from("profiles")
                .insert(profile)
                .execute()
        }

        try await fetchProfile(userId: userId)
        isAuthenticated = true
    }

    // MARK: - Sign Out

    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Auth State Listener

    func listenToAuthChanges() {
        Task {
            for await (event, session) in supabase.auth.authStateChanges {
                switch event {
                case .signedIn:
                    if let userId = session?.user.id {
                        try? await fetchProfile(userId: userId)
                    }
                    isAuthenticated = true

                case .signedOut:
                    currentUser = nil
                    isAuthenticated = false

                default:
                    break
                }
            }
        }
    }

    // MARK: - Fetch Profile

    func fetchProfile(userId: UUID) async throws {
        let profile: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        currentUser = profile
    }
}

// MARK: - Insert helper

private struct ProfileInsert: Encodable {
    let id: UUID
    let username: String
    let fullName: String?
    let phoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case id, username
        case fullName = "full_name"
        case phoneNumber = "phone_number"
    }
}
