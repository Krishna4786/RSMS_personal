import SwiftUI
internal import Combine


// MARK: - Color Theme
extension Color {
    static let storePrimary = Color(red: 0.95, green: 0.75, blue: 0.25)
    static let storeBackground = Color(red: 0.965, green: 0.965, blue: 0.965)
    static let storeCard = Color.white
    static let storeTextPrimary = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let storeTextSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)
    static let storeBanner = Color(red: 0.96, green: 0.88, blue: 0.62)
}

// MARK: - Data Models
struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let imageName: String
    let description: String
    var isFavorite: Bool = false
}

struct Category: Identifiable {
    let id = UUID()
    let name: String
}

struct SizeVariant: Identifiable {
    let id = UUID()
    let label: String
    let price: String
}

// MARK: - Banner Slide Model
struct BannerSlide: Identifiable {
    let id = UUID()
    let badge: String
    let headline: String
    let subtitle: String
    let buttonText: String
    let bgColor: Color
    let accentColor: Color
    let imageName: String
}

// MARK: - Category Card Model
struct CategoryCard: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

// MARK: - Main Home View
struct StoreMHomeView: View {
    @StateObject private var wishlistManager = WishlistManager.shared
    @State private var selectedCategory = "All"
    @State private var previewProduct: Product? = nil
    @State private var showPreview = false
    @State private var selectedProduct: Product? = nil
    @State private var navigateToDetail = false
    @State private var showNotifications = false
    @State private var currentBannerIndex = 0
    @State private var products: [Product] = [
        Product(name: "Classic T-Shirt", price: "$29.99", imageName: "tshirt", description: "A timeless wardrobe essential. Soft cotton fabric with a relaxed fit for all-day comfort."),
        Product(name: "Denim Jacket", price: "$89.99", imageName: "jacket", description: "Rugged yet refined. Premium denim with a modern cut that pairs with everything."),
        Product(name: "Summer Dress", price: "$59.99", imageName: "dress", description: "Light and breezy. Perfect for warm days with its flowy silhouette and vibrant print."),
        Product(name: "Running Shoes", price: "$119.99", imageName: "shoes", description: "Engineered for performance. Responsive cushioning with breathable mesh upper."),
        Product(name: "Casual Pants", price: "$49.99", imageName: "pants", description: "Versatile and comfortable. Stretch fabric that moves with you from day to night."),
        Product(name: "Wool Scarf", price: "$34.99", imageName: "scarf", description: "Luxuriously soft merino wool. Adds warmth and style to any cold-weather outfit."),
    ]

    let categories: [Category] = [
        Category(name: "All"),
        Category(name: "Men"),
        Category(name: "Women"),
        Category(name: "Baby"),
        Category(name: "Kids"),
        Category(name: "Shoes"),
    ]

    private let bannerSlides: [BannerSlide] = [
        BannerSlide(
            badge: "Limited Offer",
            headline: "First Purchase Enjoy\na Special Offer",
            subtitle: "Up to 40% off on selected items",
            buttonText: "Shop Now",
            bgColor: Color(red: 0.95, green: 0.75, blue: 0.25),
            accentColor: Color(red: 0.12, green: 0.12, blue: 0.14),
            imageName: "bag.fill"
        ),
        BannerSlide(
            badge: "New Season",
            headline: "Summer Collection\nJust Arrived",
            subtitle: "Fresh styles for warm days ahead",
            buttonText: "Explore",
            bgColor: Color(red: 0.85, green: 0.92, blue: 0.78),
            accentColor: Color(red: 0.12, green: 0.12, blue: 0.14),
            imageName: "sun.max.fill"
        ),
        BannerSlide(
            badge: "Members Only",
            headline: "Exclusive Access\nto Premium Picks",
            subtitle: "Join membership for early drops",
            buttonText: "Join Now",
            bgColor: Color(red: 0.82, green: 0.85, blue: 0.95),
            accentColor: Color(red: 0.12, green: 0.12, blue: 0.14),
            imageName: "crown.fill"
        ),
    ]

    private let categoryCards: [CategoryCard] = [
        CategoryCard(name: "Men's\nOutfit", icon: "figure.stand"),
        CategoryCard(name: "Women's\nOutfit", icon: "figure.stand.dress"),
        CategoryCard(name: "Men's\nFootwear", icon: "shoe.fill"),
        CategoryCard(name: "Women's\nFootwear", icon: "shoe.2.fill"),
        CategoryCard(name: "Kids\nWear", icon: "figure.child"),
        CategoryCard(name: "Accessories", icon: "bag.fill"),
    ]

    // Auto-scroll timer
    let bannerTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        greetingSection
                        bannerSection
                        categoriesSection
                        popularProductsSection
                    }
                    .padding(.bottom, 30)
                }
                .background(Color.storeBackground)
                .navigationTitle("Store.M")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(isPresented: $navigateToDetail) {
                    ProductDetailsView(product: selectedProduct)
                }
                .navigationDestination(isPresented: $showNotifications) {
                    NotificationsView()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showNotifications = true }) {
                            Image(systemName: "bell")
                                .foregroundColor(.storePrimary)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: MyCartView()) {
                            Image(systemName: "cart")
                                .foregroundColor(.storePrimary)
                                .cartBadge()
                        }
                    }
                }

                // Long-press preview overlay
                if showPreview, let product = previewProduct {
                    productPreviewOverlay(product: product)
                        .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Preview Overlay
    private func productPreviewOverlay(product: Product) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showPreview = false
                        previewProduct = nil
                    }
                }

            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.96))
                        .frame(height: 220)
                        .overlay(
                            Image(product.imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(30)
                        )

                    Button(action: {}) {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.storeTextPrimary)

                    Text(product.description)
                        .font(.system(size: 13))
                        .foregroundColor(.storeTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer().frame(height: 4)

                    HStack(spacing: 0) {
                        let variants = sizeVariants(for: product)
                        ForEach(Array(variants.enumerated()), id: \.element.id) { index, variant in
                            VStack(spacing: 4) {
                                Text(variant.price)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.storeTextPrimary)
                                Text(variant.label)
                                    .font(.system(size: 12))
                                    .foregroundColor(.storeTextSecondary)
                            }
                            .frame(maxWidth: .infinity)

                            if index < variants.count - 1 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 1, height: 34)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
            )
            .padding(.horizontal, 32)
            .scaleEffect(showPreview ? 1 : 0.85)
            .opacity(showPreview ? 1 : 0)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showPreview)
        }
    }

    private func sizeVariants(for product: Product) -> [SizeVariant] {
        let basePrice = Double(product.price.replacingOccurrences(of: "$", with: "")) ?? 29.99
        return [
            SizeVariant(label: "S", price: String(format: "$%.2f", basePrice * 0.8)),
            SizeVariant(label: "M", price: String(format: "$%.2f", basePrice)),
            SizeVariant(label: "L", price: String(format: "$%.2f", basePrice * 1.3))
        ]
    }

    // MARK: - Greeting (unchanged)
    private var greetingSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.system(size: 20))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Good Morning")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.storeTextSecondary)
                Text("Martin Butler")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.storeTextPrimary)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Banner Section (REDESIGNED)
    private var bannerSection: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentBannerIndex) {
                ForEach(Array(bannerSlides.enumerated()), id: \.element.id) { index, slide in
                    bannerCard(slide: slide)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .padding(.horizontal, 20)
            .onReceive(bannerTimer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentBannerIndex = (currentBannerIndex + 1) % bannerSlides.count
                }
            }

            // Page indicator dots
            HStack(spacing: 6) {
                ForEach(0..<bannerSlides.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentBannerIndex ? Color.storePrimary : Color.gray.opacity(0.25))
                        .frame(width: index == currentBannerIndex ? 22 : 7, height: 7)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentBannerIndex)
                }
            }
        }
        .padding(.bottom, 24)
    }

    private func bannerCard(slide: BannerSlide) -> some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let leftWidth = cardWidth * 0.58

            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [slide.bgColor, slide.bgColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Right side image area — positioned absolutely
                HStack {
                    Spacer()

                    ZStack {
                        // Soft glow behind the image
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 120, height: 120)

                        // Product image placeholder
                        Image(systemName: slide.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(slide.accentColor.opacity(0.18))
                    }
                    .frame(width: cardWidth - leftWidth - 10)
                    .padding(.trailing, 8)
                }

                // Left text content — constrained width
                VStack(alignment: .leading, spacing: 8) {
                    // Badge
                    Text(slide.badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(slide.accentColor)
                        )

                    // Headline
                    Text(slide.headline)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(slide.accentColor)
                        .lineSpacing(2)
                        .lineLimit(3)

                    Spacer(minLength: 4)

                    // CTA Button
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Text(slide.buttonText)
                                .font(.system(size: 13, weight: .bold))

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .bold))
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .fill(slide.bgColor.opacity(0.5))
                                )
                        }
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .padding(.trailing, 5)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(slide.accentColor)
                        )
                    }
                }
                .frame(width: leftWidth, alignment: .leading)
                .padding(.leading, 20)
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Categories Section (REDESIGNED)
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Categories")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.storeTextPrimary)
                Spacer()
                Button(action: {}) {
                    Text("See all")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.storeTextSecondary)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categoryCards) { card in
                        categoryCardView(card: card)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }

    private func categoryCardView(card: CategoryCard) -> some View {
        Button {
            // Navigate to category
        } label: {
            HStack(spacing: 10) {
                // Category text
                Text(card.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.storeTextPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .fixedSize(horizontal: true, vertical: false)

                // Icon placeholder (replace with images in production)
                ZStack {
                    Circle()
                        .fill(Color.storePrimary.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: card.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.storePrimary)
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 8)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(white: 0.92), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Popular Products (unchanged)
    private var popularProductsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("New Arrivals")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.storeTextPrimary)
                Spacer()
                Button(action: {}) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.storeTextSecondary)
                }
            }
            .padding(.horizontal, 20)

            let columns = [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14),
            ]

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach($products) { $product in
                    ProductCard(product: $product, onTap: {
                        selectedProduct = product
                        navigateToDetail = true
                    }, onLongPress: {
                        previewProduct = product
                        withAnimation(.easeOut(duration: 0.25)) {
                            showPreview = true
                        }
                    })
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Category Chip (kept for backwards compatibility if needed elsewhere)
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .storeTextSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.storePrimary : Color.white)
                        .shadow(
                            color: isSelected
                                ? Color.storePrimary.opacity(0.3)
                                : Color.black.opacity(0.03),
                            radius: isSelected ? 8 : 4,
                            x: 0,
                            y: isSelected ? 4 : 2
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Product Card Shape
struct ProductCardShape: Shape {
    var cornerRadius: CGFloat = 16
    var cutoutRadius: CGFloat = 24
    var filletRadius: CGFloat = 10
    var cutoutOffset: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let cr = cornerRadius
        let R = cutoutRadius
        let r = filletRadius
        let P = cutoutOffset

        let cx = w - P
        let cy = P

        let Rr = R + r
        let Pr = P - r
        let val = (Rr * Rr) - (Pr * Pr)
        let X = val > 0 ? sqrt(val) : 0

        let xc_top = cx - X
        let yc_top = r

        let xc_right = w - r
        let yc_right = cy + X

        path.move(to: CGPoint(x: cr, y: 0))
        path.addLine(to: CGPoint(x: xc_top, y: 0))

        let a1 = Angle.radians(atan2(Double(cy - yc_top), Double(cx - xc_top)))
        path.addArc(center: CGPoint(x: xc_top, y: yc_top),
                    radius: r,
                    startAngle: .degrees(-90),
                    endAngle: a1,
                    clockwise: false)

        let a2 = Angle.radians(atan2(Double(yc_top - cy), Double(xc_top - cx)))
        let a3 = Angle.radians(atan2(Double(yc_right - cy), Double(xc_right - cx)))
        path.addArc(center: CGPoint(x: cx, y: cy),
                    radius: R,
                    startAngle: a2,
                    endAngle: a3,
                    clockwise: true)

        let a4 = Angle.radians(atan2(Double(cy - yc_right), Double(cx - xc_right)))
        path.addArc(center: CGPoint(x: xc_right, y: yc_right),
                    radius: r,
                    startAngle: a4,
                    endAngle: .degrees(0),
                    clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - cr))
        path.addArc(center: CGPoint(x: w - cr, y: h - cr),
                    radius: cr,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        path.addLine(to: CGPoint(x: cr, y: h))
        path.addArc(center: CGPoint(x: cr, y: h - cr),
                    radius: cr,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: cr))
        path.addArc(center: CGPoint(x: cr, y: cr),
                    radius: cr,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)

        path.closeSubpath()
        return path
    }
}

// MARK: - Product Card
struct ProductCard: View {
    @ObservedObject private var wishlistManager = WishlistManager.shared
    @Binding var product: Product
    var onTap: () -> Void
    var onLongPress: () -> Void

    @State private var isLongPressing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Color.gray.opacity(0.12)
                .frame(height: 170)
                .overlay(
                    Image(product.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                )
                .clipShape(ProductCardShape())

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.storeTextPrimary)

                Text(product.price)
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
            heartButton,
            alignment: .topTrailing
        )
        .onTapGesture {
            if !isLongPressing {
                onTap()
            }
            isLongPressing = false
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            isLongPressing = true
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            onLongPress()
        }
    }

    private var heartButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                wishlistManager.toggleFavorite(product)
                product.isFavorite = wishlistManager.isFavorite(product)
            }

            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        } label: {
            Image(systemName: wishlistManager.isFavorite(product) ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(wishlistManager.isFavorite(product) ? .red : .gray)
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
struct StoreMHomeView_Previews: PreviewProvider {
    static var previews: some View {
        StoreMHomeView()
    }
}
