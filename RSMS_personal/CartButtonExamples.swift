import SwiftUI

/**
 Reusable Cart Button Component
 
 Use this anywhere in your app to show a cart icon with badge
 */

struct CartButton: View {
    @ObservedObject var cartManager = CartManager.shared
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "cart")
                .font(.title3)
                .foregroundColor(.primary)
                .cartBadge()
        }
    }
}

/**
 Example usage in different views
 */

// MARK: - In Navigation Bar
struct ExampleWithNavigationBar: View {
    var body: some View {
        NavigationStack {
            Text("My Store")
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CartButton {
                            // Navigate to cart
                        }
                    }
                }
        }
    }
}

// MARK: - As Floating Button
struct ExampleWithFloatingButton: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                // Your content
                Text("Products List")
            }
            
            // Floating cart button
            NavigationLink(destination: MyCartView()) {
                Image(systemName: "cart.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .shadow(radius: 8)
                    )
                    .cartBadge()
            }
            .padding()
        }
    }
}

// MARK: - In Tab Bar
struct ExampleWithTabBar: View {
    @StateObject private var cartManager = CartManager.shared
    
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            MyCartView()
                .tabItem {
                    Label {
                        Text("Cart")
                    } icon: {
                        Image(systemName: "cart")
                            .cartBadge()
                    }
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

// MARK: - Custom Styled Cart Icon
struct StyledCartButton: View {
    @ObservedObject var cartManager = CartManager.shared
    let style: CartStyle
    let action: () -> Void
    
    enum CartStyle {
        case minimal
        case outlined
        case filled
        case glass
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(iconFont)
                
                if showCount {
                    Text("\(cartManager.itemCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(foregroundColor)
            .padding(padding)
            .background(background)
            .overlay(overlayStroke)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
        }
        .buttonStyle(.plain)
    }
    
    private var iconName: String {
        switch style {
        case .minimal: return "cart"
        default: return "cart.fill"
        }
    }
    
    private var iconFont: Font {
        switch style {
        case .glass: return .title
        default: return .title3
        }
    }
    
    private var showCount: Bool {
        style == .filled || style == .glass
    }
    
    private var foregroundColor: Color {
        switch style {
        case .minimal, .outlined: return .primary
        case .filled, .glass: return .white
        }
    }
    
    private var padding: EdgeInsets {
        switch style {
        case .minimal: return EdgeInsets()
        case .outlined, .filled, .glass: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        }
    }
    
    @ViewBuilder
    private var background: some View {
        switch style {
        case .minimal:
            EmptyView()
        case .outlined:
            Capsule()
                .fill(Color(.systemBackground))
        case .filled:
            Capsule()
                .fill(Color.blue)
        case .glass:
            Capsule()
                .fill(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    private var overlayStroke: some View {
        if style == .outlined {
            Capsule()
                .stroke(Color.primary, lineWidth: 2)
        }
    }
    
    private var shadowColor: Color {
        style == .filled ? Color.black.opacity(0.2) : Color.clear
    }
    
    private var shadowRadius: CGFloat {
        style == .filled ? 8 : 0
    }
    
    private var shadowY: CGFloat {
        style == .filled ? 4 : 0
    }
}

// MARK: - Example Gallery
struct CartButtonGallery: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Group {
                        Text("Minimal Style")
                            .font(.headline)
                        StyledCartButton(style: .minimal) {}
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Outlined Style")
                            .font(.headline)
                        StyledCartButton(style: .outlined) {}
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Filled Style")
                            .font(.headline)
                        StyledCartButton(style: .filled) {}
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Glass Style")
                            .font(.headline)
                        StyledCartButton(style: .glass) {}
                    }
                    
                    Divider()
                    
                    Group {
                        Text("With Badge")
                            .font(.headline)
                        Image(systemName: "cart")
                            .font(.largeTitle)
                            .cartBadge()
                    }
                }
                .padding()
            }
            .navigationTitle("Cart Button Styles")
        }
    }
}

#Preview("Gallery") {
    CartButtonGallery()
}

#Preview("Floating") {
    ExampleWithFloatingButton()
}

#Preview("Navigation") {
    ExampleWithNavigationBar()
}
