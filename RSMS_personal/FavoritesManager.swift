import SwiftUI
import Combine

// MARK: - Favorites Manager (Shared State)
@MainActor
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteProductIds: Set<String> = []
    
    private init() {}
    
    func toggleFavorite(productId: String) {
        if favoriteProductIds.contains(productId) {
            favoriteProductIds.remove(productId)
        } else {
            favoriteProductIds.insert(productId)
        }
    }
    
    func isFavorite(productId: String) -> Bool {
        favoriteProductIds.contains(productId)
    }
    
    func removeFavorite(productId: String) {
        favoriteProductIds.remove(productId)
    }
}
