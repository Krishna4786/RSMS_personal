import SwiftUI

/**
 # Cart Integration Demo
 
 This file demonstrates how the cart system works across your app.
 
 ## Key Components:
 
 ### 1. CartManager (CartManager.swift)
 - Singleton instance managing cart state
 - Handles adding, removing, and updating items
 - Provides animation triggers
 - Observable object that updates UI automatically
 
 ### 2. Add to Cart Animation
 - Icon animates from button position to cart icon in toolbar
 - Uses spring animation for smooth motion
 - Haptic feedback for user confirmation
 - Badge shows item count on cart icon
 
 ### 3. Integration Points:
 
 **ProductDetailsView:**
 ```swift
 @StateObject private var cartManager = CartManager.shared
 
 Button(action: {
     cartManager.addToCart(
         product: currentProduct,
         color: selectedColor,
         size: selectedSize,
         quantity: 1
     )
     cartManager.triggerAddToCartAnimation(from: buttonFrame)
 })
 ```
 
 **MyCartView:**
 ```swift
 @StateObject private var cartManager = CartManager.shared
 
 // Cart automatically updates when items change
 ForEach(cartManager.cartItems) { item in
     cartItemRow(item: item)
 }
 ```
 
 **Any View (for cart badge):**
 ```swift
 Image(systemName: "cart")
     .cartBadge() // Shows item count automatically
 ```
 
 ## Features:
 
 ✅ Real-time cart updates across all screens
 ✅ Smooth animations when adding items
 ✅ Cart badge showing item count
 ✅ Quantity management (increase/decrease)
 ✅ Item removal with animation
 ✅ Empty cart state
 ✅ Persistent cart data (while app is running)
 ✅ Haptic feedback
 
 ## Usage:
 
 1. Navigate to Product Details
 2. Select color and size
 3. Tap "Add to Cart"
 4. Watch the animation fly to cart icon
 5. See badge update with item count
 6. Navigate to My Cart to see added items
 
 */

// MARK: - Demo Preview
struct CartIntegrationDemo: View {
    @StateObject private var cartManager = CartManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Cart Integration Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Cart status
                VStack(spacing: 12) {
                    HStack {
                        Text("Items in Cart:")
                            .font(.headline)
                        Spacer()
                        Text("\(cartManager.itemCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Cart Total:")
                            .font(.headline)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartManager.subtotal))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                // Navigation buttons
                VStack(spacing: 16) {
                    NavigationLink(destination: ProductDetailsView()) {
                        Text("Go to Product Details")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: MyCartView()) {
                        HStack {
                            Text("Go to My Cart")
                                .font(.headline)
                            
                            Image(systemName: "cart")
                                .cartBadge()
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Quick actions
                VStack(spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        // Add a demo item
                        let demoProduct = ProductItem(
                            sfSymbol: "star.fill",
                            name: "Demo Product",
                            price: "$29.99",
                            desc: "Demo description",
                            usdzName: nil
                        )
                        let demoColor = ProductColor(color: .blue)
                        let demoSize = ProductSize(label: "M", isAvailable: true)
                        
                        cartManager.addToCart(
                            product: demoProduct,
                            color: demoColor,
                            size: demoSize,
                            quantity: 1
                        )
                    }) {
                        Text("Add Demo Item")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        withAnimation {
                            cartManager.clearCart()
                        }
                    }) {
                        Text("Clear Cart")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                }
            }
            .padding()
            .navigationTitle("Cart Demo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "cart")
                        .font(.title3)
                        .cartBadge()
                }
            }
        }
    }
}

#Preview {
    CartIntegrationDemo()
}
