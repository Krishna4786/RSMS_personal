import SwiftUI

// MARK: - Wishlist Item Model
struct WishlistItem: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let rating: Double
    let reviews: Int
    let imageName: String
    var isFavorite: Bool = true
}

// MARK: - Wishlist View
struct WishlistView: View {
    @State private var searchText = ""
    @State private var wishlistItems: [WishlistItem] = [
        WishlistItem(name: "Dries Van Noten", price: "$580", rating: 4.8, reviews: 235, imageName: "wishlist1"),
        WishlistItem(name: "Wales Bonner", price: "$280", rating: 4.5, reviews: 163, imageName: "wishlist2"),
        WishlistItem(name: "Button Blazer", price: "$1745", rating: 4.9, reviews: 235, imageName: "wishlist3"),
        WishlistItem(name: "Still Kelly", price: "$330", rating: 4.7, reviews: 163, imageName: "wishlist4"),
        WishlistItem(name: "Dries Van Noten", price: "$580", rating: 4.8, reviews: 235, imageName: "wishlist5"),
        WishlistItem(name: "Wales Bonner", price: "$280", rating: 4.5, reviews: 163, imageName: "wishlist6")
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var filteredItems: [WishlistItem] {
        if searchText.isEmpty {
            return wishlistItems
        }
        return wishlistItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Search bar
                    searchBarSection
                        .padding(.top, 8)
                    
                    // Product grid
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                            WishlistCard(
                                item: item,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        if let idx = wishlistItems.firstIndex(where: { $0.id == item.id }) {
                                            wishlistItems.remove(at: idx)
                                        }
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
            .background(Color.storeBackground)
            .navigationTitle("Wishlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
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
    let item: WishlistItem
    let onRemove: () -> Void
    
    var body: some View {
        NavigationLink(destination: ProductDetailsView()) {
            VStack(alignment: .leading, spacing: 10) {
                // Image container with cutout shape
                Color.gray.opacity(0.10)
                    .frame(height: 170)
                    .overlay(
                        Image(item.imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    )
                    .clipShape(ProductCardShape())
                
                // Name
                Text(item.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.storeTextPrimary)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                
                // Rating + Price row
                HStack(spacing: 0) {
                    // Rating
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.storePrimary)
                        
                        Text("\(String(format: "%.1f", item.rating))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.storeTextSecondary)
                        
                        Text("(\(item.reviews))")
                            .font(.system(size: 12))
                            .foregroundColor(.storeTextSecondary)
                    }
                    
                    Spacer()
                    
                    // Price
                    Text(item.price)
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
                // Heart button in cutout area
                heartButton,
                alignment: .topTrailing
            )
        }
        .buttonStyle(.plain)
    }
    
    private var heartButton: some View {
        Button {
            onRemove()
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
