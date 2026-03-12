import SwiftUI

struct MockFriend: Identifiable {
    let id: UUID
    let name: String
    let username: String
    let hasUnwatchedAnyo: Bool
    let lastStatus: String
    let lastStatusTime: String
    var isFavorite: Bool
    let gridPosition: Int
    let color: Color
}

enum MockData {
    static let friends: [MockFriend] = [
        MockFriend(
            id: UUID(),
            name: "Sofia Reyes",
            username: "sofiareyes",
            hasUnwatchedAnyo: true,
            lastStatus: "Sent you an anyo",
            lastStatusTime: "2m ago",
            isFavorite: true,
            gridPosition: 0,
            color: Color(red: 255/255, green: 179/255, blue: 186/255) // rose
        ),
        MockFriend(
            id: UUID(),
            name: "Marcus Webb",
            username: "marcuswebb",
            hasUnwatchedAnyo: true,
            lastStatus: "Sent you an anyo",
            lastStatusTime: "11m ago",
            isFavorite: true,
            gridPosition: 1,
            color: Color(red: 179/255, green: 217/255, blue: 255/255) // sky blue
        ),
        MockFriend(
            id: UUID(),
            name: "Priya Nair",
            username: "priyanair",
            hasUnwatchedAnyo: false,
            lastStatus: "Reply back",
            lastStatusTime: "1h ago",
            isFavorite: false,
            gridPosition: 2,
            color: Color(red: 204/255, green: 255/255, blue: 204/255) // mint
        ),
        MockFriend(
            id: UUID(),
            name: "Jordan Lee",
            username: "jordanlee",
            hasUnwatchedAnyo: true,
            lastStatus: "Sent you an anyo",
            lastStatusTime: "34m ago",
            isFavorite: false,
            gridPosition: 3,
            color: Color(red: 255/255, green: 236/255, blue: 179/255) // peach
        ),
        MockFriend(
            id: UUID(),
            name: "Amara Osei",
            username: "amaraosei",
            hasUnwatchedAnyo: false,
            lastStatus: "Watched",
            lastStatusTime: "3h ago",
            isFavorite: false,
            gridPosition: 4,
            color: Color(red: 229/255, green: 204/255, blue: 255/255) // lavender
        ),
        MockFriend(
            id: UUID(),
            name: "Dante Cruz",
            username: "dantecruz",
            hasUnwatchedAnyo: false,
            lastStatus: "Watched",
            lastStatusTime: "Yesterday",
            isFavorite: false,
            gridPosition: 5,
            color: Color(red: 255/255, green: 218/255, blue: 185/255) // apricot
        ),
        MockFriend(
            id: UUID(),
            name: "Yuna Park",
            username: "yunapark",
            hasUnwatchedAnyo: true,
            lastStatus: "Sent you an anyo",
            lastStatusTime: "Just now",
            isFavorite: true,
            gridPosition: 6,
            color: Color(red: 179/255, green: 255/255, blue: 242/255) // seafoam
        ),
        MockFriend(
            id: UUID(),
            name: "Luca Ferraro",
            username: "lucaferraro",
            hasUnwatchedAnyo: false,
            lastStatus: "Sent",
            lastStatusTime: "2d ago",
            isFavorite: false,
            gridPosition: 7,
            color: Color(red: 255/255, green: 255/255, blue: 179/255) // lemon
        ),
    ]

    static let searchableUsers: [MockFriend] = [
        MockFriend(id: UUID(), name: "Mia Chen", username: "miachen", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 255/255, green: 182/255, blue: 193/255)),
        MockFriend(id: UUID(), name: "Noah Fischer", username: "noahfischer", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 173/255, green: 216/255, blue: 230/255)),
        MockFriend(id: UUID(), name: "Isla Moreno", username: "islamoreno", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 255/255, green: 228/255, blue: 181/255)),
        MockFriend(id: UUID(), name: "Kai Tanaka", username: "kaitanaka", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 200/255, green: 230/255, blue: 201/255)),
        MockFriend(id: UUID(), name: "Zara Patel", username: "zarapatel", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 225/255, green: 190/255, blue: 231/255)),
        MockFriend(id: UUID(), name: "Leo Russo", username: "leorusso", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 255/255, green: 245/255, blue: 157/255)),
        MockFriend(id: UUID(), name: "Ava Nguyen", username: "avanguyen", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 178/255, green: 235/255, blue: 242/255)),
        MockFriend(id: UUID(), name: "Ethan Brooks", username: "ethanbrooks", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 255/255, green: 205/255, blue: 210/255)),
        MockFriend(id: UUID(), name: "Chloe Kim", username: "chloekim", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 197/255, green: 225/255, blue: 165/255)),
        MockFriend(id: UUID(), name: "Omar Hassan", username: "omarhassan", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 255/255, green: 224/255, blue: 178/255)),
        MockFriend(id: UUID(), name: "Luna Silva", username: "lunasilva", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 209/255, green: 196/255, blue: 233/255)),
        MockFriend(id: UUID(), name: "Ryan O'Connor", username: "ryanoconnor", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 188/255, green: 212/255, blue: 230/255)),
        MockFriend(id: UUID(), name: "Nadia Kuznetsova", username: "nadiakuz", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 248/255, green: 187/255, blue: 208/255)),
        MockFriend(id: UUID(), name: "Tomas Andersen", username: "tomasandersen", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 200/255, green: 230/255, blue: 225/255)),
        MockFriend(id: UUID(), name: "Aisha Mbeki", username: "aishambeki", hasUnwatchedAnyo: false, lastStatus: "", lastStatusTime: "", isFavorite: false, gridPosition: 0, color: Color(red: 255/255, green: 236/255, blue: 179/255)),
    ]
}
