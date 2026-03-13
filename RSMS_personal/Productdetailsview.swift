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
}

// MARK: - Main View
struct ProductDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedColorIndex = 0
    @State private var selectedSizeIndex = 1
    @State private var currentProductIndex = 0
    @State private var rotationAngle: Double = 0
    @State private var isFavorite = false
    @State private var is360Mode = false
    @State private var dragX: Double = 0
    @State private var dragY: Double = 0
    @State private var rotationX: Double = 0

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
        ProductItem(sfSymbol: "tshirt.fill",  name: "Classic T-Shirt",  price: "$29.99",  desc: "Experience the perfect blend of comfort and style. Crafted with premium materials, this piece is designed to seamlessly integrate into your everyday wardrobe..."),
        ProductItem(sfSymbol: "shoe.fill",    name: "Running Shoes",    price: "$119.99", desc: "Engineered for speed, these shoes provide responsive cushioning and optimal breathability for all your training needs..."),
        ProductItem(sfSymbol: "bag.fill",     name: "Travel Bag",       price: "$89.99",  desc: "A spacious and durable travel companion featuring organised compartments, ready for your next weekend getaway...")
    ]

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    productInteractiveArea
                    thumbnailRow
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    productInfoCard
                }
            }
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isFavorite ? .red : .primary)
                }
            }
        }
    }

    // MARK: - SceneKit Model Loading
    private var sceneForProduct: SCNScene? {
        guard let url = Bundle.main.url(forResource: "t_shirt", withExtension: "usdz") else {
            return nil
        }
        do {
            let scene = try SCNScene(url: url, options: nil)
            scene.background.contents = UIColor.clear

            let rootNode = scene.rootNode

            // Auto-fit: read real bounding box, centre & scale to fill view
            let (minVec, maxVec) = rootNode.boundingBox
            let centerX = (minVec.x + maxVec.x) / 2
            let centerY = (minVec.y + maxVec.y) / 2
            let centerZ = (minVec.z + maxVec.z) / 2

            let sizeX = maxVec.x - minVec.x
            let sizeY = maxVec.y - minVec.y
            let sizeZ = maxVec.z - minVec.z
            let maxDimension = max(sizeX, sizeY, sizeZ)

            // Scale so longest axis = 1.8 units → camera at z:2 gives tight framing
            let scale = maxDimension > 0 ? Float(1.8 / maxDimension) : 1.0

            let containerNode = SCNNode()
            for child in rootNode.childNodes {
                containerNode.addChildNode(child)
            }
            containerNode.scale    = SCNVector3(scale, scale, scale)
            containerNode.position = SCNVector3(
                -centerX * scale,
                -centerY * scale,
                -centerZ * scale
            )
            rootNode.addChildNode(containerNode)

            // Directional key light
            let lightNode = SCNNode()
            let light = SCNLight()
            light.type        = .directional
            light.intensity   = 1800
            light.castsShadow = true
            light.shadowMode  = .deferred
            light.shadowColor = UIColor.black.withAlphaComponent(0.2)
            lightNode.light       = light
            lightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
            rootNode.addChildNode(lightNode)

            // Soft ambient fill
            let ambientLightNode = SCNNode()
            let ambientLight = SCNLight()
            ambientLight.type      = .ambient
            ambientLight.intensity = 600
            ambientLightNode.light = ambientLight
            rootNode.addChildNode(ambientLightNode)

            // Camera close for large model framing
            let cameraNode = SCNNode()
            let camera = SCNCamera()
            camera.fieldOfView  = 60           // wider FOV fills frame
            cameraNode.camera   = camera
            cameraNode.position = SCNVector3(0, 0, 2.0)
            rootNode.addChildNode(cameraNode)

            return scene
        } catch {
            print("SCNScene load error: \(error)")
            return nil
        }
    }

    // MARK: - Product Interactive Area
    private var productInteractiveArea: some View {
        // Outer ZStack lets the 3D button float over the stage without adding height
        ZStack(alignment: .bottomTrailing) {

            VStack(spacing: 0) {
                // Model Stage — fills full width, fixed height
                ZStack {
                    // Subtle colour glow only
                    Circle()
                        .fill(colors[selectedColorIndex].color.opacity(0.10))
                        .frame(width: 260, height: 260)
                        .blur(radius: 40)

                    if let scene = sceneForProduct {
                        ProductSceneView(scene: scene, allowsCameraControl: is360Mode)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .background(Color.clear)
                            .id(currentProductIndex)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: products[currentProductIndex].sfSymbol)
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
                    }
                }

                // Thin ground shadow directly under model
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.07), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 10)
                    .padding(.top, 2)

                // Rotate controls / orbit hint
                ZStack {
                    if !is360Mode {
                        HStack(spacing: 0) {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                rotateLeft()
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
                                rotateRight()
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

            // 3D/360° button — floats inside the model area, no extra height added
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    is360Mode.toggle()
                    if !is360Mode {
                        rotationAngle = 0; rotationX = 0; dragX = 0; dragY = 0
                    }
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
            // Sits at the bottom-right inside the model, above the shadow/controls
            .padding(.trailing, 16)
            .padding(.bottom, 52)
        }
        .padding(.top, 16)
    }

    // MARK: - Thumbnails
    private var thumbnailRow: some View {
        HStack(spacing: 16) {
            ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        currentProductIndex = index
                        if !is360Mode { rotationAngle = 0 }
                    }
                } label: {
                    Image(systemName: product.sfSymbol)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(
                            currentProductIndex == index
                            ? colors[selectedColorIndex].color
                            : .secondary.opacity(0.6)
                        )
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: .black.opacity(currentProductIndex == index ? 0.08 : 0.03),
                                        radius: 6, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    currentProductIndex == index
                                    ? colors[selectedColorIndex].color.opacity(0.5)
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                        .scaleEffect(currentProductIndex == index ? 1.05 : 1.0)
                }
            }
        }
    }

    // MARK: - Product Info Card
    private var productInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            let product = products[currentProductIndex]

            HStack(alignment: .top) {
                Text(product.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text(product.price)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(colors[selectedColorIndex].color)
            }

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
            Spacer().frame(height: 28)

            Button(action: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }) {
                Text("Add to Cart")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primary)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            }
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
                            .font(.system(size: 15, weight: selectedSizeIndex == index ? .bold : .medium))
                            .foregroundColor(
                                !size.isAvailable
                                ? .secondary.opacity(0.3)
                                : selectedSizeIndex == index ? Color(uiColor: .systemBackground) : .primary
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
                                : selectedSizeIndex == index ? .clear : Color(uiColor: .separator),
                                lineWidth: 1
                            ))
                            .scaleEffect(selectedSizeIndex == index ? 1.05 : 1.0)
                    }
                    .disabled(!size.isAvailable)
                }
            }
        }
    }

    // MARK: - Rotation helpers
    private func rotateLeft() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) { rotationAngle -= 360 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentProductIndex = (currentProductIndex - 1 + products.count) % products.count
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { rotationAngle = 0 }
    }

    private func rotateRight() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) { rotationAngle += 360 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentProductIndex = (currentProductIndex + 1) % products.count
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { rotationAngle = 0 }
    }
}

// MARK: - SceneKit UIViewRepresentable wrapper
struct ProductSceneView: UIViewRepresentable {
    let scene: SCNScene
    let allowsCameraControl: Bool

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene                      = scene
        scnView.allowsCameraControl        = allowsCameraControl
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode           = .multisampling4X
        scnView.backgroundColor            = .clear
        scnView.isOpaque                   = false
        scnView.layer.isOpaque             = false
        scnView.layer.backgroundColor      = UIColor.clear.cgColor
        return scnView
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
