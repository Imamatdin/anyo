import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var friendToDelete: MockFriend?
    @State private var showDeleteAlert = false
    @State private var wiggleActive = false
    @State private var selectedFriend: MockFriend?
    @State private var showCamera = false
    @State private var showAddFriendSheet = false
    @State private var showFeedback = false
    @State private var showFriendsList = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
            mainGrid

            // ── Jiggle-mode "Done" bar ───────────────────────────────────
            if viewModel.isJiggleMode {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.exitJiggleMode()
                    }
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.anyoBlue)
                }
                .transition(.move(edge: .bottom))
            }

            bottomBar
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isJiggleMode)
        .onChange(of: viewModel.isJiggleMode) { _, jiggling in
            if jiggling {
                wiggleActive = true
            } else {
                wiggleActive = false
            }
        }
        .alert("Remove \(friendToDelete?.name ?? "") from your Anyos?",
               isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { friendToDelete = nil }
            Button("Remove", role: .destructive) {
                if let id = friendToDelete?.id {
                    viewModel.removeFriend(id: id)
                }
                friendToDelete = nil
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            if let friend = selectedFriend {
                CameraView(friendName: friend.name)
            }
        }
        .sheet(isPresented: $showAddFriendSheet) {
            AddFriendSheet()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
        .fullScreenCover(isPresented: $showFriendsList) {
            NavigationStack {
                AllFriendsListView()
                    .environmentObject(viewModel)
                    .navigationTitle("Friends")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                showFriendsList = false
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Home")
                                }
                                .foregroundStyle(Color.anyoBlue)
                            }
                        }
                    }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    guard !viewModel.isJiggleMode else { return }
                    if value.translation.width > 100,
                       abs(value.translation.height) < 80,
                       value.startLocation.x < 50 {
                        showFriendsList = true
                    }
                }
        )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Spacer()
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(Color(white: 0.72))
            Spacer()
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    // MARK: - Main Grid

    private var mainGrid: some View {
        GeometryReader { geo in
            let size = viewModel.circleSize(
                for: viewModel.friendCount,
                in: geo.size.width
            )
            let columns = [
                GridItem(.adaptive(minimum: size, maximum: size + 20), spacing: 12)
            ]

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(viewModel.friends.enumerated()), id: \.element.id) { index, friend in
                        FriendCircleView(
                            name: friend.name,
                            size: size,
                            color: friend.color,
                            hasUnwatchedAnyo: friend.hasUnwatchedAnyo,
                            onTap: {
                                selectedFriend = friend
                                showCamera = true
                            },
                            isJiggleMode: viewModel.isJiggleMode,
                            onDelete: {
                                friendToDelete = friend
                                showDeleteAlert = true
                            }
                        )
                        .rotationEffect(.degrees(wiggleActive ? 2 : -2))
                        .animation(
                            wiggleActive
                                ? .easeInOut(duration: 0.15)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.05)
                                : .default,
                            value: wiggleActive
                        )
                        .onLongPressGesture(minimumDuration: 0.8) {
                            guard !viewModel.isJiggleMode else { return }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.enterJiggleMode()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            // Settings / Feedback — Anyo logo as button
            Button { showFeedback = true } label: {
                Image("AnyoLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            // Hint: only shown when the list is long enough to scroll
            if viewModel.friendCount > 12 {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.up")
                        .font(.caption2)
                    Text("swipe up to see more friends")
                        .font(.caption)
                }
                .foregroundStyle(Color(white: 0.62))
            }

            Spacer()

            // Add friend
            Button { showAddFriendSheet = true } label: {
                ZStack {
                    Circle()
                        .fill(Color.anyoBlue)
                        .frame(width: 45, height: 45)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    HomeView()
}
