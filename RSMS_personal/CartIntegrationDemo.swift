import SwiftUI

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
