# Wishlist Integration Guide

## Overview
This guide explains how the wishlist functionality is integrated across your Store.M app. Products that are favorited in the home view will automatically appear in the wishlist view.

## Architecture

### WishlistManager (Singleton)
- **Location**: `WishlistManager.swift`
- **Pattern**: Singleton with `@MainActor` for thread-safety
- **Purpose**: Centralized state management for wishlist items

```swift
@MainActor
class WishlistManager: ObservableObject {
    static let shared = WishlistManager()
    @Published var wishlistItems: [Product] = []
}
```

### Key Methods

1. **addToWishlist(_:)** - Adds a product to the wishlist
2. **removeFromWishlist(_:)** - Removes a product from the wishlist
3. **toggleFavorite(_:)** - Toggles a product's favorite status
4. **isFavorite(_:)** - Checks if a product is in the wishlist
5. **clearWishlist()** - Removes all items from the wishlist

## Integration Points

### 1. StoreMHomeView.swift
- Uses `@StateObject` to observe WishlistManager
- ProductCard hearts update the shared wishlist
- Clicking a heart adds/removes product from wishlist

```swift
@StateObject private var wishlistManager = WishlistManager.shared

// In ProductCard
Button {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        wishlistManager.toggleFavorite(product)
        product.isFavorite = wishlistManager.isFavorite(product)
    }
}
```

### 2. WishlistView.swift
- Displays all products from `wishlistManager.wishlistItems`
- Shows empty state when no items are favorited
- Allows removing items with heart button
- Includes "Clear All" button in toolbar

```swift
@StateObject private var wishlistManager = WishlistManager.shared

var filteredItems: [Product] {
    if searchText.isEmpty {
        return wishlistManager.wishlistItems
    }
    return wishlistManager.wishlistItems.filter { 
        $0.name.localizedCaseInsensitiveContains(searchText) 
    }
}
```

## Data Flow

1. User taps heart icon on a product card in StoreMHomeView
2. `wishlistManager.toggleFavorite()` is called
3. WishlistManager updates its `@Published wishlistItems` array
4. WishlistView automatically reflects changes (via `@StateObject`)
5. Heart icons across all views stay in sync

## Features

### Automatic Synchronization
- Changes in one view instantly reflect in others
- No manual refresh needed
- SwiftUI's reactive system handles updates

### Empty State
- Custom empty state view when wishlist is empty
- Encourages users to add items

### Search Functionality
- Filter wishlist items by name
- Case-insensitive search
- Real-time filtering

### Animations
- Spring animations for heart interactions
- Smooth fade in/out when adding/removing items
- Haptic feedback for better UX

### Badge Support (Optional)
You can add a wishlist badge similar to the cart badge:

```swift
.wishlistBadge() // Shows count of favorited items
```

## Best Practices

1. **Always use WishlistManager.shared** - Don't create new instances
2. **Use @StateObject in root views** - For lifecycle management
3. **Use @ObservedObject in child views** - For observation without ownership
4. **Wrap state changes in withAnimation** - For smooth transitions
5. **Add haptic feedback** - Enhances user experience

## Testing

To test the integration:

1. Navigate to the home screen
2. Tap the heart icon on any product
3. Navigate to the wishlist tab
4. Verify the product appears in the wishlist
5. Tap the heart again to remove it
6. Verify it disappears from the wishlist

## Troubleshooting

### Products not appearing in wishlist
- Ensure you're using `WishlistManager.shared`
- Check that `@StateObject` or `@ObservedObject` is properly declared
- Verify the Product model has matching `id` properties

### Hearts not staying in sync
- Make sure you're calling `wishlistManager.isFavorite(product)` to check state
- Don't rely on the local `product.isFavorite` value alone
- The source of truth is `wishlistManager.wishlistItems`

### Performance issues
- WishlistManager uses `@Published` which is efficient for small lists
- For very large wishlists (100+), consider using CoreData or SwiftData
- Current implementation is optimal for typical e-commerce use cases

## Future Enhancements

Consider adding:
- Persistence (UserDefaults, CoreData, or CloudKit)
- Wishlist sharing
- Price drop notifications
- Move to cart from wishlist
- Bulk operations (add all to cart, remove all)
