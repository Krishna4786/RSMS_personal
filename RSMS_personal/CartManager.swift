import SwiftUI
internal import Combine

// MARK: - Cart Manager
@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var cartItems: [CartItem] = []
    @Published var showAddToCartAnimation = false
    @Published var animationSourceFrame: CGRect = .zero
    
    private init() {}
    
    // Add item to cart
    func addToCart(product: ProductItem, color: ProductColor, size: ProductSize, quantity: Int = 1) {
        // Check if item with same product, color, and size exists
        if let index = cartItems.firstIndex(where: { 
            $0.name == product.name && 
            $0.size == size.label 
        }) {
            // Increase quantity
            cartItems[index].quantity += quantity
        } else {
            // Add new item
            let newItem = CartItem(
                name: product.name,
                size: size.label,
                price: parsePriceToDouble(product.price),
                imageName: product.sfSymbol,
                quantity: quantity
            )
            cartItems.append(newItem)
        }
    }
    
    // Remove item from cart
    func removeItem(at index: Int) {
        guard index < cartItems.count else { return }
        cartItems.remove(at: index)
    }
    
    // Update quantity
    func updateQuantity(at index: Int, quantity: Int) {
        guard index < cartItems.count else { return }
        if quantity <= 0 {
            removeItem(at: index)
        } else {
            cartItems[index].quantity = quantity
        }
    }
    
    // Clear cart
    func clearCart() {
        cartItems.removeAll()
    }
    
    // Calculate totals
    var subtotal: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var itemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // Trigger animation
    func triggerAddToCartAnimation(from frame: CGRect) {
        animationSourceFrame = frame
        showAddToCartAnimation = true
        
        // Hide animation after delay
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            showAddToCartAnimation = false
        }
    }
    
    // Helper to parse price string (e.g., "$29.99" -> 29.99)
    private func parsePriceToDouble(_ priceString: String) -> Double {
        let cleanedString = priceString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(cleanedString) ?? 0.0
    }
}

// MARK: - Add to Cart Animation View
struct AddToCartAnimationOverlay: View {
    @ObservedObject var cartManager = CartManager.shared
    
    var body: some View {
        ZStack {
            if cartManager.showAddToCartAnimation {
                GeometryReader { geometry in
                    AnimatedCartIcon(
                        startFrame: cartManager.animationSourceFrame,
                        geometry: geometry
                    )
                }
                .ignoresSafeArea()
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Animated Cart Icon
private struct AnimatedCartIcon: View {
    let startFrame: CGRect
    let geometry: GeometryProxy
    
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Image(systemName: "cart.fill.badge.plus")
            .font(.system(size: 40, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .position(
                x: startFrame.midX + offset.width,
                y: startFrame.midY + offset.height
            )
            .onAppear {
                // Calculate destination (top-right corner for cart icon)
                let destinationX = geometry.size.width - 60
                let destinationY: CGFloat = 60
                
                let deltaX = destinationX - startFrame.midX
                let deltaY = destinationY - startFrame.midY
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    offset = CGSize(width: deltaX, height: deltaY)
                    scale = 0.3
                }
                
                withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Cart Badge Modifier
struct CartBadge: ViewModifier {
    @ObservedObject var cartManager = CartManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if cartManager.itemCount > 0 {
                    Text("\(cartManager.itemCount)")
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
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cartManager.itemCount)
    }
}

extension View {
    func cartBadge() -> some View {
        modifier(CartBadge())
    }
}
