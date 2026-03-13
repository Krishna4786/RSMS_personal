import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: 0) {
                StoreMHomeView()
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
