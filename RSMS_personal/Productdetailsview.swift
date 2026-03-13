import SwiftUI

// MARK: - Models
struct ProductColor: Identifiable {
    let id = UUID()
    let color: Color
}

struct ProductSize: Identifiable {
    let id = UUID()
    let label: String
    let isAvailable: Bool
}

struct ProductItem: Identifiable {
    let id = UUID()
    let sfSymbol: String
}

// MARK: - Main View
struct ProductDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedColorIndex = 0
    @State private var selectedSizeIndex = 1
    @State private var currentProductIndex = 0
    @State private var rotationAngle: Double = 0
    @State private var isAnimating = false
    @State private var isFavorite = false
    
    private let colors: [ProductColor] = [
        ProductColor(color: Color(red: 0.20, green: 0.45, blue: 0.80)),
        ProductColor(color: Color(red: 0.90, green: 0.65, blue: 0.20)),
        ProductColor(color: Color(red: 0.90, green: 0.35, blue: 0.35)),
        ProductColor(color: Color(red: 0.30, green: 0.80, blue: 0.70))
    ]
    
    private let sizes: [ProductSize] = [
        ProductSize(label: "S", isAvailable: true),
        ProductSize(label: "M", isAvailable: true),
        ProductSize(label: "L", isAvailable: true),
        ProductSize(label: "XL", isAvailable: true),
        ProductSize(label: "XXL", isAvailable: false)
    ]
    
    private let products: [ProductItem] = [
        ProductItem(sfSymbol: "tshirt.fill"),
        ProductItem(sfSymbol: "shoe.fill"),
        ProductItem(sfSymbol: "bag.fill")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // ── Product Display ──
                productDisplaySection
                
                // ── Thumbnails ──
                thumbnailRow
                    .padding(.top, 16)
                
                // ── Product Info Card ──
                productInfoCard
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                
                Spacer().frame(height: 40)
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Only the trailing heart button — system handles the back button
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }
            }
        }
    }
    
    // MARK: - Product Display
    private var productDisplaySection: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 30)
            
            // Main rotating product
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                colors[selectedColorIndex].color.opacity(0.06),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                
                Image(systemName: products[currentProductIndex].sfSymbol)
                    .font(.system(size: 130, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                colors[selectedColorIndex].color,
                                colors[selectedColorIndex].color.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotation3DEffect(
                        .degrees(rotationAngle),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .id(currentProductIndex)
            }
            .frame(height: 200)
            
            Spacer().frame(height: 20)
            
            // Oval ring + shadow
            ZStack {
                Ellipse()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 220, height: 40)
                
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [.black.opacity(0.06), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 180, height: 20)
            }
            
            Spacer().frame(height: 10)
            
            // Rotation arrows
            HStack(spacing: 5) {
                Button { rotateLeft() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray.opacity(0.7))
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.35))
                    .frame(width: 1, height: 12)
                
                Button { rotateRight() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
            )
        }
    }
    
    // MARK: - Thumbnails
    private var thumbnailRow: some View {
        HStack(spacing: 12) {
            ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentProductIndex = index
                    }
                } label: {
                    Image(systemName: product.sfSymbol)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(
                            currentProductIndex == index
                            ? colors[selectedColorIndex].color
                            : .gray.opacity(0.35)
                        )
                        .frame(width: 52, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    currentProductIndex == index
                                    ? Color(red: 0.82, green: 0.64, blue: 0.22)
                                    : Color.gray.opacity(0.10),
                                    lineWidth: currentProductIndex == index ? 1.8 : 0.8
                                )
                        )
                        .shadow(
                            color: currentProductIndex == index
                            ? Color(red: 0.82, green: 0.64, blue: 0.22).opacity(0.15)
                            : .clear,
                            radius: 4, y: 2
                        )
                }
            }
        }
    }
    
    // MARK: - Product Info Card
    private var productInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title + Price
            HStack(alignment: .top) {
                Text("Bomber Jacket")
                    .font(.system(size: 22, weight: .bold))
                
                Spacer()
                
                Text("$108.00")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colors[selectedColorIndex].color)
            }
            
            Spacer().frame(height: 10)
            
            // Description
            Text("The bomber jacket is a timeless piece known for its casual yet stylish appeal. Originally designed for pilots, it now adds a bold, edgy touch to everyday fashion...")
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.48))
                .lineSpacing(4)
            
            Spacer().frame(height: 20)
            
            // Select Color
            colorSelector
            
            Spacer().frame(height: 18)
            
            // Select Size
            sizeSelector
            
            Spacer().frame(height: 24)
            
            // Buy Now
            Button(action: {}) {
                Text("Buy Now")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(red: 0.13, green: 0.16, blue: 0.22))
                    )
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        )
    }
    
    // MARK: - Color Selector
    private var colorSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Color")
                .font(.system(size: 13, weight: .semibold))
            
            HStack(spacing: 12) {
                ForEach(Array(colors.enumerated()), id: \.element.id) { index, item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedColorIndex = index
                        }
                    } label: {
                        Circle()
                            .fill(item.color)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: selectedColorIndex == index ? 3 : 0)
                                    .frame(width: 27, height: 27)
                            )
                            .shadow(
                                color: selectedColorIndex == index
                                ? item.color.opacity(0.35) : .clear,
                                radius: 4, y: 2
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Size Selector
    private var sizeSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Size")
                .font(.system(size: 13, weight: .semibold))
            
            HStack(spacing: 8) {
                ForEach(Array(sizes.enumerated()), id: \.element.id) { index, size in
                    Button {
                        guard size.isAvailable else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSizeIndex = index
                        }
                    } label: {
                        Text(size.label)
                            .font(.system(size: 13, weight: selectedSizeIndex == index ? .bold : .medium))
                            .foregroundColor(
                                !size.isAvailable
                                ? .gray.opacity(0.3)
                                : selectedSizeIndex == index ? .white : .black
                            )
                            .frame(width: 36, height: 36)
                            .background(
                                Circle().fill(
                                    selectedSizeIndex == index
                                    ? Color(red: 0.18, green: 0.30, blue: 0.55)
                                    : .clear
                                )
                            )
                            .overlay(
                                Circle().stroke(
                                    !size.isAvailable
                                    ? Color.gray.opacity(0.15)
                                    : selectedSizeIndex == index
                                    ? .clear : Color.gray.opacity(0.25),
                                    lineWidth: 1
                                )
                            )
                    }
                    .disabled(!size.isAvailable)
                }
            }
        }
    }
    
    // MARK: - Rotation
    private func rotateLeft() {
        guard !isAnimating else { return }
        isAnimating = true
        withAnimation(.easeInOut(duration: 0.45)) { rotationAngle = -360 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentProductIndex = (currentProductIndex - 1 + products.count) % products.count
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            rotationAngle = 0
            isAnimating = false
        }
    }
    
    private func rotateRight() {
        guard !isAnimating else { return }
        isAnimating = true
        withAnimation(.easeInOut(duration: 0.45)) { rotationAngle = 360 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentProductIndex = (currentProductIndex + 1) % products.count
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            rotationAngle = 0
            isAnimating = false
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProductDetailsView()
    }
}
