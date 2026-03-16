import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var homePath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: 0) {
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
            
            Tab("Wishlist", systemImage: "heart", value: 1) {
                WishlistView()
            }
            Tab("Membership", systemImage: "crown", value: 3) {
                MembershipView()
            }
            Tab("Orders", systemImage: "bag", value: 2) {
                MyOrdersView()
            }
            
            Tab("Profile", systemImage: "person", value: 4) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(Color.storePrimary)
    }
}

#Preview {
    MainTabView()
}
