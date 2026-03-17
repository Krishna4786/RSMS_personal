import SwiftUI

// MARK: - Wishlist View
struct WishlistView: View {
    @StateObject private var wishlistManager = WishlistManager.shared
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var filteredItems: [Product] {
        if searchText.isEmpty {
            return wishlistManager.wishlistItems
        }
        return wishlistManager.wishlistItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if wishlistManager.wishlistItems.isEmpty {
                        emptyStateView
                    } else {
                        // Search bar
                        searchBarSection
                            .padding(.top, 8)
                        
                        // Product grid
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(filteredItems) { item in
                                WishlistCard(
                                    product: item,
                                    onRemove: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            wishlistManager.removeFromWishlist(item)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer().frame(height: 30)
                    }
                }
            }
            .background(Color.storeBackground)
            .navigationTitle("Wishlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !wishlistManager.wishlistItems.isEmpty {
                        Button(action: {
                            withAnimation {
                                wishlistManager.clearWishlist()
                            }
                        }) {
                            Text("Clear All")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "heart.slash")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.storeTextSecondary.opacity(0.5))
            
            Text("Your Wishlist is Empty")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.storeTextPrimary)
            
            Text("Add products you love by tapping the heart icon")
                .font(.system(size: 14))
                .foregroundColor(.storeTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Search Bar
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.storeTextSecondary)
                
                TextField("Search", text: $searchText)
                    .font(.system(size: 15))
                    .foregroundColor(.storeTextPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color.white)
            .cornerRadius(44)
            .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 2)
            
            Button(action: {}) {
                Circle()
                    .fill(Color.storePrimary)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }
}

// MARK: - Wishlist Card
struct WishlistCard: View {
    @ObservedObject private var wishlistManager = WishlistManager.shared
    let product: Product
    let onRemove: () -> Void
    
    var body: some View {
        NavigationLink(destination: ProductDetailsView(product: product)) {
            VStack(alignment: .leading, spacing: 12) {
                // IMAGE CONTAINER
                Color.gray.opacity(0.12)
                    .frame(height: 170)
                    .overlay(
                        Image(product.imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    )
                    .clipShape(ProductCardShape())
                
                // PRODUCT INFO
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.storeTextPrimary)
                    
                    Text(product.price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.storeTextPrimary)
                }
                .padding(.horizontal, 4)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.storeCard)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(white: 0.90), lineWidth: 1.0)
            )
            .overlay(
                heartButton,
                alignment: .topTrailing
            )
        }
        .buttonStyle(.plain)
    }
    
    private var heartButton: some View {
        Button {
            onRemove()
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        } label: {
            Image(systemName: "heart.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 36, height: 36)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                .overlay(Circle().stroke(Color(white: 0.90), lineWidth: 1.0))
        }
        .padding(.trailing, 12)
        .padding(.top, 12)
    }
}

// MARK: - Preview
#Preview {
    WishlistView()
}
