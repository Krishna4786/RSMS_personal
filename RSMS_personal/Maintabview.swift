import SwiftUI

// MARK: - Main Tab View (Native iOS TabView with Search)
struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var homePath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - Home Tab
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

            // MARK: - Wishlist Tab
            Tab("Wishlist", systemImage: "heart.fill", value: 1) {
                NavigationStack {
                    WishlistView()
                }
            }

            // MARK: - Membership Tab
            Tab("Membership", systemImage: "crown.fill", value: 2) {
                NavigationStack {
                    MembershipView()
                }
            }

            // MARK: - Profile Tab
            Tab("Profile", systemImage: "person.fill", value: 3) {
                NavigationStack {
                    ProfileView()
                }
            }

            // MARK: - Search Tab (Native search role — appears as a floating search icon)
            Tab("Search", systemImage: "magnifyingglass", value: 4, role: .search) {
                NavigationStack {
                    SearchView()
                }
            }
        }
        .tint(Color.storePrimary)
    }
}

// MARK: - Search View (Full native search experience)
struct SearchView: View {
    @State private var searchText = ""

    private let recentSearches = [
        "Winter Coat",
        "Denim Jacket",
        "Running Shoes",
        "Classic T-Shirt",
    ]

    private let trendingItems = [
        "New Arrivals",
        "Sale Items",
        "Jordan Collection",
        "Accessories",
        "Summer Essentials",
    ]

    private let suggestedCategories: [(name: String, icon: String, color: Color)] = [
        ("Men", "figure.stand", Color(red: 0.30, green: 0.50, blue: 0.85)),
        ("Women", "figure.stand.dress", Color(red: 0.85, green: 0.40, blue: 0.55)),
        ("Kids", "figure.child", Color(red: 0.95, green: 0.60, blue: 0.20)),
        ("Shoes", "shoe.fill", Color(red: 0.55, green: 0.40, blue: 0.80)),
        ("Accessories", "bag.fill", Color(red: 0.25, green: 0.70, blue: 0.55)),
        ("Sports", "figure.run", Color(red: 0.90, green: 0.35, blue: 0.30)),
    ]

    var body: some View {
        List {
            // MARK: - Recent Searches
            if searchText.isEmpty {
                Section {
                    ForEach(recentSearches, id: \.self) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(width: 24)

                            Text(item)
                                .font(.system(size: 16))

                            Spacer()

                            Image(systemName: "arrow.up.left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    HStack {
                        Text("Recent Searches")
                        Spacer()
                        Button("Clear") {
                            // Clear recent searches
                        }
                        .font(.system(size: 13, weight: .medium))
                        .textCase(nil)
                    }
                }

                // MARK: - Trending
                Section("Trending") {
                    ForEach(trendingItems, id: \.self) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.trend.up")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.storePrimary)
                                .frame(width: 24)

                            Text(item)
                                .font(.system(size: 16))
                        }
                        .padding(.vertical, 2)
                    }
                }

                // MARK: - Browse Categories
                Section("Browse Categories") {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ], spacing: 12) {
                        ForEach(suggestedCategories, id: \.name) { category in
                            categoryCard(name: category.name, icon: category.icon, color: category.color)
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Products, brands, categories...")
    }

    // MARK: - Category Card
    private func categoryCard(name: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)

            Text(name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }
}


// MARK: - Preview
#Preview {
    MainTabView()
}
