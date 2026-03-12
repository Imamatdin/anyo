import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var selectedUser: MockFriend?
    @State private var showConfirmation = false
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // ── Segmented picker ─────────────────────────────────────
            Picker("", selection: $selectedTab) {
                Text("By Username").tag(0)
                Text("From Contacts").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // ── Search bar ───────────────────────────────────────────
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(white: 0.5))
                TextField("Search...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.anyoText)
                    .focused($searchFocused)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(white: 0.94))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // ── Content ──────────────────────────────────────────────
            if selectedTab == 0 {
                usernameSearchContent
            } else {
                contactsPlaceholder
            }
        }
        .background(Color.white)
        .navigationTitle("Add Friend")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { searchFocused = true }
        .alert(selectedUser?.name ?? "", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) { selectedUser = nil }
            Button("Send Friend Request") {
                if let user = selectedUser {
                    addFriend(user)
                }
            }
        }
    }

    // MARK: - Username Search

    private var usernameSearchContent: some View {
        let results = filteredUsers
        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(results) { user in
                    Button {
                        selectedUser = user
                        showConfirmation = true
                    } label: {
                        userRow(user)
                    }
                    .buttonStyle(.plain)
                }

                if results.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(white: 0.7))
                        Text("No users found")
                            .font(.subheadline)
                            .foregroundStyle(Color(white: 0.55))
                    }
                    .padding(.top, 60)
                }
            }
            .padding(.top, 8)
        }
    }

    private var filteredUsers: [MockFriend] {
        let query = searchText.lowercased()
        if query.isEmpty { return MockData.searchableUsers }
        return MockData.searchableUsers.filter {
            $0.name.lowercased().contains(query) ||
            $0.username.lowercased().contains(query)
        }
    }

    private func userRow(_ user: MockFriend) -> some View {
        HStack(spacing: 12) {
            // Colored circle with initial
            ZStack {
                Circle()
                    .fill(user.color)
                    .frame(width: 40, height: 40)
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("@\(user.username)")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.anyoText)
                Text(user.name)
                    .font(.caption)
                    .foregroundStyle(Color(white: 0.55))
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }

    private func addFriend(_ user: MockFriend) {
        print("Friend request sent to \(user.name)")
        let newFriend = MockFriend(
            id: user.id,
            name: user.name,
            username: user.username,
            hasUnwatchedAnyo: false,
            lastStatus: "Just added",
            lastStatusTime: "Now",
            isFavorite: false,
            gridPosition: viewModel.friendCount,
            color: user.color
        )
        viewModel.addFriend(newFriend)
        dismiss()
    }

    // MARK: - Contacts Placeholder

    private var contactsPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 48))
                .foregroundStyle(Color(white: 0.7))

            Text("Contacts access will be requested")
                .font(.subheadline)
                .foregroundStyle(Color(white: 0.55))

            Button {
                print("Requesting contacts permission")
            } label: {
                Text("Allow Access")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.anyoBlue)
                    .clipShape(Capsule())
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        AddFriendView()
            .environmentObject(HomeViewModel())
    }
}
