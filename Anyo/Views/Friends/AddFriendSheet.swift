import SwiftUI

struct AddFriendSheet: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationLink {
                    AddFriendView()
                        .environmentObject(viewModel)
                } label: {
                    sheetRow(
                        icon: "person.badge.plus",
                        iconColor: Color.anyoBlue,
                        title: "Add Someone"
                    )
                }

                Divider()
                    .padding(.horizontal, 16)

                NavigationLink {
                    RemindersView()
                        .environmentObject(viewModel)
                } label: {
                    sheetRow(
                        icon: "bell.badge",
                        iconColor: .orange,
                        title: "Set Reminder"
                    )
                }

                Spacer()
            }
            .padding(.top, 20)
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.anyoText)
                }
            }
        }
    }

    private func sheetRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.anyoText)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(white: 0.7))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
}

#Preview {
    AddFriendSheet()
        .environmentObject(HomeViewModel())
}
