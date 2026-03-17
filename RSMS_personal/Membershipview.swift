import SwiftUI

// MARK: - Transaction Model
struct Transaction: Identifiable {
    let id = UUID()
    let productName: String
    let category: String
    let points: Int
    let imageName: String
}

// MARK: - Side Menu Item
struct SideMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}

// MARK: - Membership View
struct MembershipView: View {

    @State private var cardAppeared = false
    @State private var menuAppeared = false
    @State private var transactionsAppeared = false
    @State private var shimmerOffset: CGFloat = -200

    private let sideMenuItems: [SideMenuItem] = [
        SideMenuItem(icon: "star.fill", label: "My Points"),
        SideMenuItem(icon: "person.2.fill", label: "My Benefits"),
        SideMenuItem(icon: "calendar.badge.clock", label: "Appointments"),
    ]

    private let transactions: [Transaction] = [
        Transaction(productName: "Jordan Lows", category: "Shoes", points: 20, imageName: "shoe"),
        Transaction(productName: "Classic Tee", category: "Apparel", points: 15, imageName: "tshirt"),
        Transaction(productName: "Jordan Lows", category: "Shoes", points: 20, imageName: "shoe"),
        Transaction(productName: "Wool Scarf", category: "Accessories", points: 10, imageName: "scarf"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Card + Side Menu Section
                    cardSection
                        .padding(.top, 20)

                    // MARK: - Recent Transactions
                    transactionsSection
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
            }
            .background(Color(red: 0.93, green: 0.93, blue: 0.93))
            .navigationTitle("Membership")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .onAppear { triggerAnimations() }
        }
    }

    // MARK: - Card Section with Side Menu
    private var cardSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                // Left Side Menu
                VStack(spacing: 20) {
                    ForEach(Array(sideMenuItems.enumerated()), id: \.element.id) { index, item in
                        sideMenuButton(item: item, index: index)
                    }
                }
                .padding(.leading, 8)

                Spacer(minLength: 10)

                // Card Stack
                cardStack
                    .padding(.trailing, 20)
            }
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.88, green: 0.88, blue: 0.88))
            )
            .padding(.horizontal, 16)

            // Valid Till
            HStack {
                Spacer()
                Text("Valid Till Dec 2026")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(white: 0.45))
                    .padding(.top, 10)
                    .padding(.trailing, 28)
            }
        }
    }

    // MARK: - Side Menu Button
    private func sideMenuButton(item: SideMenuItem, index: Int) -> some View {
        Button {
            // Handle tap
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 48, height: 48)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)

                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }

                Text(item.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 85)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(.plain)
        .offset(x: menuAppeared ? 0 : -60)
        .opacity(menuAppeared ? 1 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.12 + 0.3),
            value: menuAppeared
        )
    }

    // MARK: - Card Stack
    private var cardStack: some View {
        ZStack {
            // Back card (tilted left)
            memberCard(opacity: 0.35)
                .rotationEffect(.degrees(cardAppeared ? -8 : 0), anchor: .bottom)
                .scaleEffect(cardAppeared ? 0.92 : 0.95)
                .offset(x: cardAppeared ? -14 : 0, y: cardAppeared ? 6 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.5), value: cardAppeared)

            // Middle card (tilted right)
            memberCard(opacity: 0.6)
                .rotationEffect(.degrees(cardAppeared ? 5 : 0), anchor: .bottom)
                .scaleEffect(cardAppeared ? 0.96 : 0.98)
                .offset(x: cardAppeared ? 8 : 0, y: cardAppeared ? 3 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.35), value: cardAppeared)

            // Front card (main)
            mainCard
                .scaleEffect(cardAppeared ? 1.0 : 0.85)
                .opacity(cardAppeared ? 1.0 : 0)
                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.15), value: cardAppeared)
        }
        .frame(width: 220, height: 300)
    }

    // MARK: - Background Card (faded)
    private func memberCard(opacity: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.28, blue: 0.32).opacity(opacity),
                        Color(red: 0.35, green: 0.38, blue: 0.42).opacity(opacity),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 200, height: 280)
    }

    // MARK: - Main Card
    private var mainCard: some View {
        ZStack {
            // Card background gradient
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.24, blue: 0.28),
                            Color(red: 0.32, green: 0.35, blue: 0.40),
                            Color(red: 0.25, green: 0.28, blue: 0.32),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Shimmer overlay
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.0),
                            .white.opacity(0.08),
                            .white.opacity(0.0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: shimmerOffset)
                .mask(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                )

            // Card content
            VStack(alignment: .leading, spacing: 0) {
                // Top: Member + Active badge
                HStack {
                    Text("Member")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("Active")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.22, green: 0.78, blue: 0.42))
                        )
                }
                .padding(.bottom, 20)

                Spacer()

                // Center: Brand logo
                VStack(spacing: 6) {
                    // Interlocking C's approximation
                    Image(systemName: "infinity")
                        .font(.system(size: 38, weight: .thin))
                        .foregroundColor(.white.opacity(0.7))

                    Text("CHANEL")
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)

                Spacer()

                // Bottom: Member name
                Text("Krishna Aggarwal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                // Member ID
                Text("ID: MBR-2026-0451")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 3)
            }
            .padding(20)
        }
        .frame(width: 200, height: 280)
        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
    }

    // MARK: - Transactions Section
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Button {
                    // See all
                } label: {
                    Text("See All")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(white: 0.45))
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                    transactionRow(transaction: transaction, index: index)

                    if index < transactions.count - 1 {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
            )
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Transaction Row
    private func transactionRow(transaction: Transaction, index: Int) -> some View {
        HStack(spacing: 14) {
            // Product thumbnail
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.93, green: 0.93, blue: 0.94))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: productIcon(for: transaction.category))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(white: 0.55))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.productName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Text(transaction.category)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(white: 0.6))
            }

            Spacer()

            // Points
            Text("+ \(transaction.points) points")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.20, green: 0.75, blue: 0.40))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .opacity(transactionsAppeared ? 1 : 0)
        .offset(y: transactionsAppeared ? 0 : 20)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.1 + 0.8),
            value: transactionsAppeared
        )
    }

    // MARK: - Helpers
    private func productIcon(for category: String) -> String {
        switch category.lowercased() {
        case "shoes":       return "shoe.fill"
        case "apparel":     return "tshirt.fill"
        case "accessories": return "scarf.fill"
        default:            return "bag.fill"
        }
    }

    private func triggerAnimations() {
        // Stagger the animations
        withAnimation { cardAppeared = true }
        withAnimation { menuAppeared = true }
        withAnimation { transactionsAppeared = true }

        // Continuous shimmer loop
        startShimmer()
    }

    private func startShimmer() {
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: false)
            .delay(1.0)
        ) {
            shimmerOffset = 250
        }
    }
}

// MARK: - Preview
#Preview {
    MembershipView()
}
