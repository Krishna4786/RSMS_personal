import SwiftUI

// MARK: - Cart Item Model
struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let size: String
    let price: Double
    let imageName: String
    var quantity: Int
}

// MARK: - My Cart View
struct MyCartView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cartManager = CartManager.shared
    
    @State private var promoCode: String = ""
    @State private var showSuccessAnimation = false
    @State private var navigateToTracking = false
    @State private var showCheckoutOptions = false
    @State private var navigateToStoreLocator = false
    
    private var subtotal: Double {
        cartManager.subtotal
    }
    
    private let shipping: Double = 45.99
    
    private var bagTotal: Double {
        subtotal + shipping
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if cartManager.cartItems.isEmpty {
                // Empty cart state
                emptyCartView
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Cart items
                        VStack(spacing: 12) {
                            ForEach(Array(cartManager.cartItems.enumerated()), id: \.element.id) { index, item in
                                cartItemRow(item: item, index: index)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Promo code
                        promoCodeSection
                            .padding(.horizontal, 20)
                            .padding(.top, 28)
                        
                        // Order summary
                        orderSummary
                            .padding(.horizontal, 20)
                            .padding(.top, 28)
                        
                        // Space for bottom button
                        Spacer().frame(height: 120)
                    }
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                
                // Pinned checkout button
                checkoutButton
            }
        }
        .navigationTitle("My Cart")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !cartManager.cartItems.isEmpty {
                    Button(action: {
                        withAnimation {
                            cartManager.clearCart()
                        }
                    }) {
                        Text("Clear")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showSuccessAnimation, onDismiss: {
            // Navigate to order tracking after sheet dismisses
            navigateToTracking = true
        }) {
            SuccessAnimationView(
                title: "Order Placed!",
                message: "Your order has been placed successfully and is being processed."
            )
        }
        .navigationDestination(isPresented: $navigateToTracking) {
            OrderTrackingView()
        }
        .navigationDestination(isPresented: $navigateToStoreLocator) {
            StoreLocatorView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRootHome)) { _ in
            // Reset navigation state when pop to root is triggered
            navigateToStoreLocator = false
            navigateToTracking = false
        }
        .sheet(isPresented: $showCheckoutOptions) {
            CheckoutOptionsSheet(
                onPickupSelected: {
                    showCheckoutOptions = false
                    // Navigate to store locator for pickup
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToStoreLocator = true
                    }
                },
                onDeliverySelected: {
                    showCheckoutOptions = false
                    // Handle delivery flow
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSuccessAnimation = true
                    }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }
    
    // MARK: - Empty Cart View
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 80, weight: .thin))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("Your Cart is Empty")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Add items to your cart to see them here")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
    }
    
    // MARK: - Cart Item Row
    private func cartItemRow(item: CartItem, index: Int) -> some View {
        HStack(spacing: 14) {
            // Product image placeholder
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.92, green: 0.92, blue: 0.93))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: item.imageName)
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.gray.opacity(0.4))
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("Size - \(item.size)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Delete button
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            cartManager.removeItem(at: index)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundColor(Color(red: 0.95, green: 0.55, blue: 0.10))
                    }
                }
                
                Spacer().frame(height: 6)
                
                HStack {
                    Text("Rs. \(Int(item.price))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Quantity controls
                    HStack(spacing: 12) {
                        Button {
                            cartManager.updateQuantity(at: index, quantity: item.quantity - 1)
                        } label: {
                            Text("–")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        Text("\(item.quantity)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(minWidth: 14)
                        
                        Button {
                            cartManager.updateQuantity(at: index, quantity: item.quantity + 1)
                        } label: {
                            Text("+")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    // MARK: - Promo Code
    private var promoCodeSection: some View {
        HStack(spacing: 0) {
            TextField("Promo Code", text: $promoCode)
                .font(.system(size: 15))
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            
            Button(action: {}) {
                Text("Apply")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black)
                    )
            }
            .padding(.trailing, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }
    
    // MARK: - Order Summary
    private var orderSummary: some View {
        VStack(spacing: 0) {
            summaryRow(label: "Subtotal", value: "Rs. \(String(format: "%.2f", subtotal))", suffix: "INR")
            
            Divider()
                .padding(.vertical, 14)
            
            summaryRow(label: "Shipping", value: "Rs. \(String(format: "%.2f", shipping))", suffix: "INR")
            
            Divider()
                .padding(.vertical, 14)
            
            summaryRow(label: "Bag Total", value: "Rs. \(String(format: "%.2f", bagTotal))", suffix: "INR", isBold: true)
        }
    }
    
    private func summaryRow(label: String, value: String, suffix: String, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: isBold ? .bold : .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 15, weight: isBold ? .bold : .medium))
                    .foregroundColor(.black)
                
                Text(suffix)
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
    
    // MARK: - Checkout Button
    private var checkoutButton: some View {
        VStack(spacing: 0) {
            Button(action: {
                showCheckoutOptions = true
            }) {
                Text("Proceed To Checkout")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.black)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 5)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Checkout Options Sheet
struct CheckoutOptionsSheet: View {
    let onPickupSelected: () -> Void
    let onDeliverySelected: () -> Void
    
    @State private var selectedOption: CheckoutOption = .pickup
    
    enum CheckoutOption {
        case pickup, delivery
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 20)
            
            // Title
            Text("Choose Any option How you want to get your Order")
                .font(.system(size: 15))
                .foregroundColor(Color(white: 0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 32)
            
            // Options
            HStack(spacing: 20) {
                // Pickup option
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedOption = .pickup
                    }
                }) {
                    VStack(spacing: 12) {
                        Text("Order Now Pickup\nAt Store")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        Text("Collect your order directly from the selected store once it is ready.")
                            .font(.system(size: 11))
                            .foregroundColor(Color(white: 0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(red: 30/255, green: 42/255, blue: 53/255))
                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color(red: 240/255, green: 168/255, blue: 50/255), lineWidth: selectedOption == .pickup ? 3 : 0)
                    )
                    .scaleEffect(selectedOption == .pickup ? 1.02 : 1.0)
                }
                .buttonStyle(.plain)
                
                // Delivery option
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedOption = .delivery
                    }
                }) {
                    VStack(spacing: 12) {
                        Text("Online Delivery")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        Text("Get your order delivered to your address within the estimated delivery time.")
                            .font(.system(size: 11))
                            .foregroundColor(Color(white: 0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(red: 30/255, green: 42/255, blue: 53/255))
                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color(red: 240/255, green: 168/255, blue: 50/255), lineWidth: selectedOption == .delivery ? 3 : 0)
                    )
                    .scaleEffect(selectedOption == .delivery ? 1.02 : 1.0)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 32)
            
            // Confirm button
            Button(action: {
                if selectedOption == .pickup {
                    onPickupSelected()
                } else {
                    onDeliverySelected()
                }
            }) {
                Text("Confirm Selection")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.black)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.92, green: 0.92, blue: 0.92))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MyCartView()
    }
}
