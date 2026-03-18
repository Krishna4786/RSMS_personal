import SwiftUI

// MARK: - Subscription Plan
enum SubPlan: String, CaseIterable, Identifiable {
    case monthly, halfYearly, yearly
    var id: String { rawValue }

    var duration: String {
        switch self {
        case .monthly: return "1"; case .halfYearly: return "6"; case .yearly: return "1"
        }
    }
    var unit: String {
        switch self {
        case .monthly: return "Month"; case .halfYearly: return "Months"; case .yearly: return "Year"
        }
    }
    var price: String {
        switch self {
        case .monthly: return "₹499"; case .halfYearly: return "₹2,499"; case .yearly: return "₹3,999"
        }
    }
    var perMonth: String {
        switch self {
        case .monthly: return "₹499/mo"; case .halfYearly: return "₹416/mo"; case .yearly: return "₹333/mo"
        }
    }
    var saveBadge: String? {
        switch self {
        case .monthly: return nil; case .halfYearly: return "Save 17%"; case .yearly: return "Save 33%"
        }
    }
    var recommended: Bool { self == .yearly }
}

// MARK: - Floating Particle
struct FloatingParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let delay: Double
}

// MARK: - Membership Splash View
struct MembershipSplashView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubPlan = .yearly

    // Animation states
    @State private var appeared = false
    @State private var cardRotation: Double = 0
    @State private var cardFloat: CGFloat = 0
    @State private var shimmerPhase: CGFloat = -1
    @State private var benefitsRevealed = false
    @State private var plansRevealed = false
    @State private var ctaRevealed = false
    @State private var glowPulse: CGFloat = 0.4
    @State private var particlesActive = false

    private let particles: [FloatingParticle] = (0..<18).map { _ in
        FloatingParticle(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 2...5),
            opacity: Double.random(in: 0.15...0.5),
            duration: Double.random(in: 4...8),
            delay: Double.random(in: 0...3)
        )
    }

    private let benefits: [(icon: String, title: String, sub: String)] = [
        ("calendar.badge.clock", "Priority Appointments", "Exclusive in-store styling sessions"),
        ("star.fill", "Reward Points", "Earn points on every purchase"),
        ("gift.fill", "Occasion Discounts", "Birthday, anniversary & celebration offers"),
        ("bolt.fill", "Early Access", "Shop new drops before everyone"),
    ]

    // Colors
    private let bgDark = Color(red: 0.06, green: 0.06, blue: 0.08)
    private let cardDark = Color(red: 0.10, green: 0.10, blue: 0.13)
    private let gold = Color(red: 0.90, green: 0.72, blue: 0.25)
    private let goldLight = Color(red: 0.98, green: 0.88, blue: 0.55)
    private let goldDim = Color(red: 0.65, green: 0.52, blue: 0.18)

    var body: some View {
        ZStack {
            // MARK: - Background
            bgDark.ignoresSafeArea()

            // Floating particles
            particleField
                .ignoresSafeArea()

            // Radial glow behind card
            RadialGradient(
                colors: [gold.opacity(glowPulse * 0.12), .clear],
                center: .init(x: 0.5, y: 0.28),
                startRadius: 40,
                endRadius: 280
            )
            .ignoresSafeArea()

            // Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Membership Card
                    membershipCard
                        .padding(.top, 56)

                    // MARK: - Benefits
                    benefitsList
                        .padding(.top, 36)

                    // MARK: - Plan Selector
                    planSelector
                        .padding(.top, 32)

                    // MARK: - CTA
                    ctaButton
                        .padding(.top, 32)

                    // MARK: - Footer
                    footer
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                }
            }

            // Close
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(.white.opacity(0.08)))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { runAnimations() }
    }

    // MARK: - Particle Field
    private var particleField: some View {
        GeometryReader { geo in
            ForEach(particles) { p in
                Circle()
                    .fill(gold.opacity(particlesActive ? p.opacity : 0))
                    .frame(width: p.size, height: p.size)
                    .position(
                        x: p.x * geo.size.width,
                        y: particlesActive
                            ? (p.y * geo.size.height) - 60
                            : (p.y * geo.size.height) + 60
                    )
                    .animation(
                        .easeInOut(duration: p.duration)
                            .repeatForever(autoreverses: true)
                            .delay(p.delay),
                        value: particlesActive
                    )
            }
        }
    }

    // MARK: - 3D Membership Card
    private var membershipCard: some View {
        VStack(spacing: 16) {
            ZStack {
                // Card
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.14, green: 0.14, blue: 0.18), location: 0),
                                .init(color: Color(red: 0.10, green: 0.10, blue: 0.14), location: 0.5),
                                .init(color: Color(red: 0.14, green: 0.14, blue: 0.18), location: 1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 280, height: 175)
                    .overlay(
                        // Shimmer sweep
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, gold.opacity(0.08), goldLight.opacity(0.15), gold.opacity(0.08), .clear],
                                    startPoint: UnitPoint(x: shimmerPhase - 0.3, y: 0),
                                    endPoint: UnitPoint(x: shimmerPhase + 0.3, y: 1)
                                )
                            )
                    )
                    .overlay(
                        // Card border glow
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [gold.opacity(0.5), gold.opacity(0.1), gold.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .overlay(
                        // Card content
                        cardContent
                    )
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0.1, y: 1, z: 0),
                        perspective: 0.4
                    )
                    .offset(y: cardFloat)
                    .shadow(color: gold.opacity(0.15), radius: 30, y: 15)
            }

            // Brand
            VStack(spacing: 6) {
                Text("STORE.M")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(6)
                    .foregroundColor(gold.opacity(0.6))

                Text("Premium Membership")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Text("Unlock rewards, perks & exclusive access")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.45))
            }
            .padding(.top, 6)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 40)
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1), value: appeared)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("MEMBER")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(3)
                    .foregroundColor(gold.opacity(0.7))

                Spacer()

                Text("PREMIUM")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [gold, goldLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }

            Spacer()

            // Center logo
            HStack {
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [gold, goldLight, gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Spacer()
            }

            Spacer()

            // Bottom
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Krishna Aggarwal")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                    Text("Since 2026")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }

                Spacer()

                // Decorative dots
                HStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { _ in
                        Circle()
                            .fill(gold.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .padding(20)
    }

    // MARK: - Benefits List
    private var benefitsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { index, b in
                HStack(spacing: 16) {
                    // Glowing icon circle
                    ZStack {
                        Circle()
                            .fill(gold.opacity(0.08))
                            .frame(width: 44, height: 44)

                        Image(systemName: b.icon)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(gold)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(b.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)

                        Text(b.sub)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Spacer()

                    // Animated check
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(bgDark)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle().fill(gold)
                        )
                        .scaleEffect(benefitsRevealed ? 1 : 0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.5)
                                .delay(Double(index) * 0.12 + 0.6),
                            value: benefitsRevealed
                        )
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
                .opacity(benefitsRevealed ? 1 : 0)
                .offset(x: benefitsRevealed ? 0 : -40)
                .animation(
                    .spring(response: 0.55, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1 + 0.4),
                    value: benefitsRevealed
                )

                if index < benefits.count - 1 {
                    Rectangle()
                        .fill(.white.opacity(0.04))
                        .frame(height: 1)
                        .padding(.horizontal, 22)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Plan Selector
    private var planSelector: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.system(size: 13, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.35))
                .textCase(.uppercase)

            HStack(spacing: 12) {
                ForEach(SubPlan.allCases) { plan in
                    planCard(plan)
                }
            }
            .padding(.horizontal, 20)

            // Summary
            Text(selectedPlan == .monthly ? "₹499 billed monthly"
                 : selectedPlan == .halfYearly ? "₹2,499 billed every 6 months"
                 : "₹3,999 billed annually — best deal")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.35))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: selectedPlan)
        }
        .opacity(plansRevealed ? 1 : 0)
        .offset(y: plansRevealed ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: plansRevealed)
    }

    private func planCard(_ plan: SubPlan) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedPlan = plan
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 8) {
                // Recommended badge
                if plan.recommended {
                    Text("BEST VALUE")
                        .font(.system(size: 8, weight: .heavy))
                        .tracking(1.5)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(colors: [gold, goldLight], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                } else if let save = plan.saveBadge {
                    Text(save)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .stroke(gold.opacity(0.4), lineWidth: 1)
                        )
                } else {
                    Spacer().frame(height: 18)
                }

                // Duration
                Text(plan.duration)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? gold : .white.opacity(0.7))

                Text(plan.unit)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))

                // Per month
                Text(plan.perMonth)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.top, 2)

                // Divider line
                Rectangle()
                    .fill(isSelected ? gold.opacity(0.3) : .white.opacity(0.05))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                // Price
                Text(plan.price)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? gold.opacity(0.08) : cardDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                isSelected
                                    ? LinearGradient(colors: [gold, goldDim], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [.white.opacity(0.06), .white.opacity(0.02)], startPoint: .top, endPoint: .bottom),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? gold.opacity(0.12) : .clear, radius: 16, y: 6)
            .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            // Handle subscription
        } label: {
            ZStack {
                // Glow behind
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(gold.opacity(0.25))
                    .blur(radius: 12)
                    .frame(height: 56)
                    .offset(y: 4)

                // Button
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [gold, Color(red: 0.82, green: 0.62, blue: 0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 56)

                // Shimmer sweep on button
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.2), .clear],
                            startPoint: UnitPoint(x: shimmerPhase - 0.2, y: 0),
                            endPoint: UnitPoint(x: shimmerPhase + 0.2, y: 1)
                        )
                    )
                    .frame(height: 56)

                Text("Get Premium Membership")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .opacity(ctaRevealed ? 1 : 0)
        .offset(y: ctaRevealed ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: ctaRevealed)
    }

    // MARK: - Footer
    private var footer: some View {
        VStack(spacing: 10) {
            Button("Restore Purchase") {}
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.3))

            Text("Auto-renews unless cancelled 24 hrs before renewal.\nCancel anytime in App Store settings.")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.2))
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            HStack(spacing: 14) {
                Button("Terms of Service") {}
                Button("Privacy Policy") {}
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white.opacity(0.25))
        }
    }

    // MARK: - Animations
    private func runAnimations() {
        // Phase 1: Card entrance
        withAnimation { appeared = true }
        withAnimation { benefitsRevealed = true }
        withAnimation { plansRevealed = true }
        withAnimation { ctaRevealed = true }

        // Particles float
        withAnimation { particlesActive = true }

        // Card subtle rotation oscillation
        withAnimation(
            .easeInOut(duration: 4)
            .repeatForever(autoreverses: true)
        ) {
            cardRotation = 6
        }

        // Card float
        withAnimation(
            .easeInOut(duration: 3)
            .repeatForever(autoreverses: true)
            .delay(0.5)
        ) {
            cardFloat = -8
        }

        // Shimmer loop on card + CTA
        withAnimation(
            .linear(duration: 3)
            .repeatForever(autoreverses: false)
            .delay(0.8)
        ) {
            shimmerPhase = 2
        }

        // Glow pulse
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
        ) {
            glowPulse = 0.8
        }
    }
}

// MARK: - Preview
#Preview {
    MembershipSplashView()
}
