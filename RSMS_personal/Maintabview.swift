import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var homePath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab("Home", systemImage: "house.fill", value: 0) {
                NavigationStack(path: $homePath) {
                    StoreMHomeView()
                }
                .environment(\.popToRoot) {
                    homePath = NavigationPath()
                }
                .onReceive(NotificationCenter.default.publisher(for: .popToRootHome)) { _ in
                    homePath = NavigationPath()
                }
            }

            Tab("Wishlist", systemImage: "heart.fill", value: 1) {
                NavigationStack {
                    WishlistView()
                }
            }

            // No NavigationStack wrapper — MembershipView handles it internally
            Tab("Membership", systemImage: "crown.fill", value: 2) {
                MembershipView()
            }

            Tab("Profile", systemImage: "person.fill", value: 3) {
                NavigationStack {
                    ProfileView()
                }
            }

            Tab("Search", systemImage: "magnifyingglass", value: 4, role: .search) {
                NavigationStack {
                    SearchView()
                }
            }
        }
        .tint(Color.storePrimary)
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
