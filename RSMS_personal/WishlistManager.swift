import SwiftUI
internal import Combine

// MARK: - Wishlist Manager
@MainActor
class WishlistManager: ObservableObject {
    static let shared = WishlistManager()
    
    @Published var wishlistItems: [Product] = []
    
    private init() {}
    
    // Add item to wishlist
    func addToWishlist(_ product: Product) {
        // Check if product already exists
        if !wishlistItems.contains(where: { $0.id == product.id }) {
            var updatedProduct = product
            updatedProduct.isFavorite = true
            wishlistItems.append(updatedProduct)
        }
    }
    
    // Remove item from wishlist
    func removeFromWishlist(_ product: Product) {
        wishlistItems.removeAll { $0.id == product.id }
    }
    
    // Toggle favorite status
    func toggleFavorite(_ product: Product) {
        if wishlistItems.contains(where: { $0.id == product.id }) {
            removeFromWishlist(product)
        } else {
            addToWishlist(product)
        }
    }
    
    // Check if product is favorited
    func isFavorite(_ product: Product) -> Bool {
        wishlistItems.contains(where: { $0.id == product.id })
    }
    
    // Clear wishlist
    func clearWishlist() {
        wishlistItems.removeAll()
    }
    
    // Get wishlist count
    var itemCount: Int {
        wishlistItems.count
    }
}

// MARK: - Wishlist Badge Modifier
struct WishlistBadge: ViewModifier {
    @ObservedObject var wishlistManager = WishlistManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if wishlistManager.itemCount > 0 {
                    Text("\(wishlistManager.itemCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 16, minHeight: 16)
                        .padding(2)
                        .background(
                            Circle()
                                .fill(.red)
                        )
                        .offset(x: 6, y: -6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: wishlistManager.itemCount)
    }
}

extension View {
    func wishlistBadge() -> some View {
        modifier(WishlistBadge())
    }
}
