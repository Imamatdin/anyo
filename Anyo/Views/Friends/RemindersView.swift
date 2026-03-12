import SwiftUI
import UserNotifications

struct RemindersView: View {
    @EnvironmentObject private var viewModel: HomeViewModel

    @State private var friendForReminder: MockFriend?
    @State private var showPicker = false

    private let frequencies = ["Everyday", "Every 3 days", "Weekly", "Never"]

    var body: some View {
        VStack(spacing: 0) {
            // ── Gradient header ──────────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color.anyoBlue, Color(red: 77/255, green: 208/255, blue: 225/255)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                Text("REMINDERS")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(1.5)
            }
            .frame(height: 44)

            // ── Friend list ──────────────────────────────────────────
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.friends) { friend in
                        reminderRow(friend)
                        Divider().padding(.leading, 76)
                    }
                }
            }
        }
        .background(Color.white)
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPicker) {
            if let friend = friendForReminder {
                frequencyPicker(for: friend)
                    .presentationDetents([.height(280)])
            }
        }
    }

    // MARK: - Row

    private func reminderRow(_ friend: MockFriend) -> some View {
        let currentFreq = viewModel.reminders[friend.id]

        return HStack(spacing: 12) {
            FriendCircleView(
                name: friend.name,
                size: 45,
                color: friend.color,
                hasUnwatchedAnyo: false,
                onTap: {},
                showNameOnDrag: false
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.name)
                    .font(.body)
                    .foregroundStyle(Color.anyoText)

                let firstName = friend.name.split(separator: " ").first.map(String.init) ?? friend.name
                let freq = currentFreq ?? "Not set"
                Text("Remind me to Anyo \(firstName): \(freq)")
                    .font(.caption)
                    .foregroundStyle(Color(white: 0.55))
            }

            Spacer()

            Button {
                friendForReminder = friend
                showPicker = true
            } label: {
                if currentFreq != nil {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.anyoBlue)
                } else {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }

    // MARK: - Frequency Picker

    private func frequencyPicker(for friend: MockFriend) -> some View {
        VStack(spacing: 0) {
            Text("Remind me to Anyo \(friend.name.split(separator: " ").first ?? "")")
                .font(.headline)
                .foregroundStyle(Color.anyoText)
                .padding(.top, 20)
                .padding(.bottom, 16)

            ForEach(frequencies, id: \.self) { freq in
                Button {
                    selectFrequency(freq, for: friend)
                    showPicker = false
                } label: {
                    HStack {
                        Text(freq)
                            .font(.body)
                            .foregroundStyle(freq == "Never" ? .red : Color.anyoText)
                        Spacer()
                        if viewModel.reminders[friend.id] == freq {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.anyoBlue)
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                }
            }

            Spacer()
        }
    }

    // MARK: - Schedule Notification

    private func selectFrequency(_ frequency: String, for friend: MockFriend) {
        if frequency == "Never" {
            viewModel.reminders.removeValue(forKey: friend.id)
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [friend.id.uuidString]
            )
            return
        }

        viewModel.reminders[friend.id] = frequency

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            let firstName = friend.name.split(separator: " ").first.map(String.init) ?? friend.name
            content.title = "Time to Anyo!"
            content.body = "Send \(firstName) a quick anyo \u{1F427}"
            content.sound = .default

            let seconds: TimeInterval = switch frequency {
            case "Everyday":      86400
            case "Every 3 days":  259200
            case "Weekly":        604800
            default:              86400
            }

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: seconds,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: friend.id.uuidString,
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }
}

#Preview {
    NavigationStack {
        RemindersView()
            .environmentObject(HomeViewModel())
    }
}
