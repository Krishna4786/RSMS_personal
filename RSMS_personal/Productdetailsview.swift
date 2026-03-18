import SwiftUI
import SceneKit

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
    let name: String
    let price: String
    let desc: String
    let usdzName: String?
}

// MARK: - Main View
struct ProductDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cartManager = CartManager.shared
    @StateObject private var wishlistManager = WishlistManager.shared
    
    var product: Product?

    @State private var selectedColorIndex  = 0
    @State private var selectedSizeIndex   = 1
    @State private var currentProductIndex = 0
    @State private var flipDegrees: Double = 0
    @State private var isFlipping = false
    @State private var is360Mode = false
    @State private var addToCartButtonFrame: CGRect = .zero

    private let colors: [ProductColor] = [
        ProductColor(color: Color(red: 0.20, green: 0.45, blue: 0.80)),
        ProductColor(color: Color(red: 0.90, green: 0.65, blue: 0.20)),
        ProductColor(color: Color(red: 0.90, green: 0.35, blue: 0.35)),
        ProductColor(color: Color(red: 0.30, green: 0.80, blue: 0.70))
    ]

    private let sizes: [ProductSize] = [
        ProductSize(label: "S",   isAvailable: true),
        ProductSize(label: "M",   isAvailable: true),
        ProductSize(label: "L",   isAvailable: true),
        ProductSize(label: "XL",  isAvailable: true),
        ProductSize(label: "XXL", isAvailable: false)
    ]

    private let products: [ProductItem] = [
        ProductItem(sfSymbol: "tshirt.fill",
                    name: "Classic T-Shirt",
                    price: "$29.99",
                    desc: "Experience the perfect blend of comfort and style. Crafted with premium materials, this piece is designed to seamlessly integrate into your everyday wardrobe...",
                    usdzName: "t_shirt"),
        ProductItem(sfSymbol: "shoe.fill",
                    name: "Running Shoes",
                    price: "$119.99",
                    desc: "Engineered for speed, these shoes provide responsive cushioning and optimal breathability for all your training needs...",
                    usdzName: nil),
        ProductItem(sfSymbol: "bag.fill",
                    name: "Travel Bag",
                    price: "$89.99",
                    desc: "A spacious and durable travel companion featuring organised compartments, ready for your next weekend getaway...",
                    usdzName: nil)
    ]

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        productInteractiveArea
                        // Thumbnail row removed
                        productInfoCard
                            .padding(.top, 16)
                    }
                }

                // MARK: - Fixed Bottom Add to Cart Bar
                bottomCartBar
            }

            AddToCartAnimationOverlay()
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: MyCartView()) {
                    Image(systemName: "cart")
                        .foregroundColor(.storePrimary)
                        .cartBadge()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if let product = product {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            wishlistManager.toggleFavorite(product)
                        }
                    }
                } label: {
                    let isFavorited = product.map { wishlistManager.isFavorite($0) } ?? false
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .foregroundColor(isFavorited ? .red : .storePrimary)
                }
            }
        }
    }

    // MARK: - Fixed Bottom Cart Bar
    private var bottomCartBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 16) {
                // Price display
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Price")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(products[currentProductIndex].price)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

                GeometryReader { geo in
                    Button(action: {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)

                        let currentProduct = products[currentProductIndex]
                        let selectedColor = colors[selectedColorIndex]
                        let selectedSize = sizes[selectedSizeIndex]

                        cartManager.addToCart(
                            product: currentProduct,
                            color: selectedColor,
                            size: selectedSize,
                            quantity: 1
                        )

                        addToCartButtonFrame = geo.frame(in: .global)
                        cartManager.triggerAddToCartAnimation(from: addToCartButtonFrame)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add to Cart")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule()
                                .fill(Color.primary)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                    }
                }
                .frame(height: 52)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 2)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: - SceneKit Scene Builder
    private func buildScene(usdzName: String) -> SCNScene? {
        guard let url = Bundle.main.url(forResource: usdzName, withExtension: "usdz") else {
            return nil
        }
        guard let scene = try? SCNScene(url: url, options: nil) else { return nil }

        scene.background.contents = UIColor.clear
        let root = scene.rootNode

        let (minV, maxV) = root.boundingBox
        let center = SCNVector3((minV.x + maxV.x) / 2,
                                (minV.y + maxV.y) / 2,
                                (minV.z + maxV.z) / 2)
        let maxDim = max(maxV.x - minV.x, maxV.y - minV.y, maxV.z - minV.z)
        let scale  = maxDim > 0 ? Float(1.8 / maxDim) : 1.0

        let container = SCNNode()
        for child in root.childNodes { container.addChildNode(child) }
        container.scale    = SCNVector3(scale, scale, scale)
        container.position = SCNVector3(-center.x * scale, -center.y * scale, -center.z * scale)
        root.addChildNode(container)

        let keyNode  = SCNNode(); let key = SCNLight()
        key.type = .directional; key.intensity = 1800
        key.castsShadow = true; key.shadowMode = .deferred
        key.shadowColor = UIColor.black.withAlphaComponent(0.2)
        keyNode.light = key
        keyNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        root.addChildNode(keyNode)

        let ambNode  = SCNNode(); let amb = SCNLight()
        amb.type = .ambient; amb.intensity = 600
        ambNode.light = amb; root.addChildNode(ambNode)

        let camNode = SCNNode(); let cam = SCNCamera()
        cam.fieldOfView = 60; camNode.camera = cam
        camNode.position = SCNVector3(0, 0, 2.0)
        root.addChildNode(camNode)

        return scene
    }

    // MARK: - Product Interactive Area
    private var productInteractiveArea: some View {
        let product = products[currentProductIndex]
        let scene   = product.usdzName.flatMap { buildScene(usdzName: $0) }

        return ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(colors[selectedColorIndex].color.opacity(0.10))
                        .frame(width: 260, height: 260)
                        .blur(radius: 40)

                    if let scene = scene {
                        ProductSceneView(scene: scene,
                                         allowsCameraControl: is360Mode)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .background(Color.clear)
                            .id(currentProductIndex)
                            .transition(.scale.combined(with: .opacity))
                            .rotation3DEffect(.degrees(flipDegrees),
                                              axis: (x: 0, y: 1, z: 0),
                                              perspective: 0.4)
                    } else {
                        Image(systemName: product.sfSymbol)
                            .font(.system(size: 160, weight: .thin))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        colors[selectedColorIndex].color.opacity(0.7),
                                        colors[selectedColorIndex].color
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: colors[selectedColorIndex].color.opacity(0.3),
                                    radius: 10, y: 10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .rotation3DEffect(.degrees(flipDegrees),
                                              axis: (x: 0, y: 1, z: 0),
                                              perspective: 0.4)
                            .id(currentProductIndex)
                    }
                }

                Ellipse()
                    .fill(
                        RadialGradient(colors: [Color.black.opacity(0.07), .clear],
                                       center: .center, startRadius: 0, endRadius: 70)
                    )
                    .frame(width: 140, height: 10)
                    .padding(.top, 2)

                ZStack {
                    if !is360Mode {
                        HStack(spacing: 0) {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                flipProduct(direction: -1)
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 44, height: 36)
                                    .foregroundColor(.primary)
                            }
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 1, height: 14)
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                flipProduct(direction: 1)
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 44, height: 36)
                                    .foregroundColor(.primary)
                            }
                        }
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 12))
                            Text("Orbit with finger")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.secondary)
                        .frame(height: 36)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
                .padding(.top, 10)
            }

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    is360Mode.toggle()
                    if !is360Mode { flipDegrees = 0 }
                }
            } label: {
                VStack(spacing: 3) {
                    Text("3D")
                        .font(.system(size: 18, weight: .semibold))
                    Text("360°")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                }
                .foregroundColor(.primary)
                .frame(width: 52, height: 54)
                .background(Color(uiColor: .systemBackground).opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary, lineWidth: is360Mode ? 1.5 : 0)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 52)
        }
        .padding(.top, 16)
    }

    // MARK: - Product Info Card (Add to Cart button removed — it's now in the bottom bar)
    private var productInfoCard: some View {
        let product = products[currentProductIndex]

        return VStack(alignment: .leading, spacing: 0) {
            Text(product.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Spacer().frame(height: 10)

            Text(product.desc)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 24)
            colorSelector
            Spacer().frame(height: 20)
            sizeSelector
            Spacer().frame(height: 16)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 24, y: 8)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Color Selector
    private var colorSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Color")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            HStack(spacing: 16) {
                ForEach(Array(colors.enumerated()), id: \.element.id) { index, item in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedColorIndex = index
                        }
                    } label: {
                        Circle()
                            .fill(item.color)
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(Color(uiColor: .systemBackground),
                                                     lineWidth: selectedColorIndex == index ? 3 : 0))
                            .overlay(
                                Circle()
                                    .stroke(item.color.opacity(0.5),
                                            lineWidth: selectedColorIndex == index ? 2 : 0)
                                    .scaleEffect(selectedColorIndex == index ? 1.25 : 1.0)
                                    .opacity(selectedColorIndex == index ? 1 : 0)
                            )
                            .shadow(color: selectedColorIndex == index ? item.color.opacity(0.4) : .clear,
                                    radius: 8, y: 4)
                    }
                }
            }
        }
    }

    // MARK: - Size Selector
    private var sizeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Size")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            HStack(spacing: 12) {
                ForEach(Array(sizes.enumerated()), id: \.element.id) { index, size in
                    Button {
                        guard size.isAvailable else { return }
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSizeIndex = index
                        }
                    } label: {
                        Text(size.label)
                            .font(.system(size: 15,
                                          weight: selectedSizeIndex == index ? .bold : .medium))
                            .foregroundColor(
                                !size.isAvailable
                                ? .secondary.opacity(0.3)
                                : selectedSizeIndex == index
                                    ? Color(uiColor: .systemBackground)
                                    : .primary
                            )
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(
                                selectedSizeIndex == index
                                ? Color.primary
                                : Color(uiColor: .secondarySystemBackground)
                            ))
                            .overlay(Circle().stroke(
                                !size.isAvailable
                                ? Color.gray.opacity(0.1)
                                : selectedSizeIndex == index
                                    ? .clear
                                    : Color(uiColor: .separator),
                                lineWidth: 1
                            ))
                            .scaleEffect(selectedSizeIndex == index ? 1.05 : 1.0)
                    }
                    .disabled(!size.isAvailable)
                }
            }
        }
    }

    // MARK: - Flip Logic
    private func flipProduct(direction: Double) {
        guard !isFlipping else { return }
        isFlipping = true
        withAnimation(.easeInOut(duration: 0.5)) {
            flipDegrees += direction * 180
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            isFlipping = false
        }
    }
}

// MARK: - SceneKit UIViewRepresentable
struct ProductSceneView: UIViewRepresentable {
    let scene: SCNScene
    let allowsCameraControl: Bool

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene                      = scene
        v.allowsCameraControl        = allowsCameraControl
        v.autoenablesDefaultLighting = false
        v.antialiasingMode           = .multisampling4X
        v.backgroundColor            = .clear
        v.isOpaque                   = false
        v.layer.isOpaque             = false
        v.layer.backgroundColor      = UIColor.clear.cgColor
        return v
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.allowsCameraControl = allowsCameraControl
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProductDetailsView()
    }
}
