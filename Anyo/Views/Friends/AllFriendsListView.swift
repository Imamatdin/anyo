import SwiftUI

struct AllFriendsListView: View {
    @EnvironmentObject private var viewModel: HomeViewModel

    var body: some View {
        List {
            newAnyosSection
            myFriendsSection
        }
        .listStyle(.plain)
        .background(Color.white.ignoresSafeArea())
        .scrollContentBackground(.hidden)
    }

    // MARK: - New Anyos

    @ViewBuilder
    private var newAnyosSection: some View {
        let unwatched = viewModel.friends.filter(\.hasUnwatchedAnyo)

        if !unwatched.isEmpty {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(unwatched) { friend in
                            VStack(spacing: 6) {
                                FriendCircleView(
                                    name: friend.name,
                                    size: 65,
                                    color: friend.color,
                                    hasUnwatchedAnyo: true,
                                    onTap: { print("Tapped \(friend.name)") },
                                    showNameOnDrag: false
                                )

                                Text(firstName(friend.name))
                                    .font(.caption)
                                    .foregroundStyle(Color.anyoText)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            } header: {
                Text("New Anyos")
                    .font(.headline).bold()
                    .foregroundStyle(Color(red: 255/255, green: 213/255, blue: 79/255))
                    .textCase(nil)
                    .padding(.leading, 16)
            }
        }
    }

    // MARK: - My Friends

    private var myFriendsSection: some View {
        Section {
            ForEach(viewModel.friends) { friend in
                friendRow(friend)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            print("Remove \(friend.name)")
                        } label: {
                            Label("Remove", systemImage: "person.fill.xmark")
                        }

                        Button {
                            viewModel.toggleFavorite(id: friend.id)
                        } label: {
                            Label("Favorite", systemImage: "star.fill")
                        }
                        .tint(.yellow)
                    }
            }
        } header: {
            Text("My Friends")
                .font(.headline).bold()
                .foregroundStyle(Color(red: 77/255, green: 208/255, blue: 225/255))
                .textCase(nil)
                .padding(.leading, 16)
        }
    }

    // MARK: - Friend row

    private func friendRow(_ friend: MockFriend) -> some View {
        HStack(spacing: 12) {
            FriendCircleView(
                name: friend.name,
                size: 50,
                color: friend.color,
                hasUnwatchedAnyo: false,
                onTap: {},
                showNameOnDrag: false
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.anyoText)

                Text("\(friend.lastStatus) \(friend.lastStatusTime)")
                    .font(.caption)
                    .foregroundStyle(Color(white: 0.55))
            }

            Spacer()

            if friend.isFavorite {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(red: 255/255, green: 193/255, blue: 7/255))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

    private func firstName(_ fullName: String) -> String {
        fullName.split(separator: " ").first.map(String.init) ?? fullName
    }
}

#Preview {
    AllFriendsListView()
        .environmentObject(HomeViewModel())
}
