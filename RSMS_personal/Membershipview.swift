import SwiftUI

// MARK: - Membership Color Theme
extension Color {
    static let memberGold = Color(red: 0.95, green: 0.75, blue: 0.25)
    static let memberDark = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let memberAccent = Color(red: 1.0, green: 0.80, blue: 0.30)
}

// MARK: - Membership Benefit
struct MembershipBenefit: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

// MARK: - Plan Option
struct PlanOption: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let per: String
    let savings: String?
    let isPopular: Bool
}

// MARK: - Points Activity
struct PointsActivity: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let points: String
    let isEarned: Bool
}

// MARK: - Appointment
struct MemberAppointment: Identifiable {
    let id = UUID()
    let type: String
    let date: String
    let time: String
    let status: String
}

// MARK: - Main Membership View (Router)
struct MembershipView: View {
    @State private var isMember = false
    
    var body: some View {
        NavigationStack {
            if isMember {
                MembershipDashboardView(isMember: $isMember)
            } else {
                MembershipIntroView(isMember: $isMember)
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - INTRO / SPLASH SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MembershipIntroView: View {
    @Binding var isMember: Bool
    @State private var selectedPlan = 1
    @State private var animateIn = false
    
    private let benefits: [MembershipBenefit] = [
        MembershipBenefit(icon: "shippingbox.fill", title: "Free Delivery", subtitle: "Unlimited free shipping on all orders"),
        MembershipBenefit(icon: "calendar.badge.clock", title: "Book Appointments", subtitle: "Priority scheduling & exclusive slots"),
        MembershipBenefit(icon: "star.circle.fill", title: "Points System", subtitle: "Earn & redeem points on every purchase"),
        MembershipBenefit(icon: "tag.fill", title: "Exclusive Deals", subtitle: "Members-only discounts & early access"),
        MembershipBenefit(icon: "arrow.counterclockwise", title: "Extended Returns", subtitle: "60-day hassle-free return window"),
    ]
    
    private let plans: [PlanOption] = [
        PlanOption(name: "Monthly", price: "₹199", per: "/month", savings: nil, isPopular: false),
        PlanOption(name: "Yearly", price: "₹1,499", per: "/year", savings: "Save 37%", isPopular: true),
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.memberDark,
                    Color(red: 0.12, green: 0.11, blue: 0.14),
                    Color(red: 0.10, green: 0.09, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Decorative gold circles
            Circle()
                .fill(Color.memberGold.opacity(0.06))
                .frame(width: 300, height: 300)
                .offset(x: -120, y: -280)
            
            Circle()
                .fill(Color.memberGold.opacity(0.04))
                .frame(width: 200, height: 200)
                .offset(x: 140, y: -180)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 20)
                    
                    // Crown icon
                    ZStack {
                        Circle()
                            .fill(Color.memberGold.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.memberGold)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)
                    
                    Spacer().frame(height: 20)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("STORE.M")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(4)
                            .foregroundColor(.memberGold)
                        
                        Text("Go Premium")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(.white)
                        
                        Text("Unlock the full Store.M experience\nwith exclusive member benefits")
                            .font(.system(size: 15))
                            .foregroundColor(Color(white: 0.55))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 15)
                    
                    Spacer().frame(height: 32)
                    
                    // Benefits list
                    VStack(spacing: 0) {
                        ForEach(Array(benefits.enumerated()), id: \.element.id) { index, benefit in
                            benefitRow(benefit: benefit)
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 10)
                                .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08 + 0.2), value: animateIn)
                            
                            if index < benefits.count - 1 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.06))
                                    .frame(height: 1)
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 28)
                    
                    // Plan selector
                    Text("Choose your plan")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(white: 0.50))
                        .tracking(1)
                    
                    Spacer().frame(height: 14)
                    
                    HStack(spacing: 12) {
                        ForEach(Array(plans.enumerated()), id: \.element.id) { index, plan in
                            planCard(plan: plan, isSelected: selectedPlan == index, index: index)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 28)
                    
                    // CTA Button
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isMember = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Get Started")
                                .font(.system(size: 17, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.memberDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [.memberGold, .memberAccent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .memberGold.opacity(0.3), radius: 16, y: 6)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Skip
                    Button {
                        isMember = true
                    } label: {
                        Text("Maybe later")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.45))
                    }
                    .padding(.top, 14)
                    
                    // Terms
                    Text("Recurring billing, cancel anytime.\nTerms & Conditions apply.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.30))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                    
                    Spacer().frame(height: 30)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
        }
    }
    
    // Benefit row
    private func benefitRow(benefit: MembershipBenefit) -> some View {
        HStack(spacing: 14) {
            Image(systemName: benefit.icon)
                .font(.system(size: 18))
                .foregroundColor(.memberGold)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.memberGold.opacity(0.12))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(benefit.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(benefit.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.50))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.memberGold.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // Plan card
    private func planCard(plan: PlanOption, isSelected: Bool, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlan = index
            }
        } label: {
            VStack(spacing: 8) {
                if let savings = plan.savings {
                    Text(savings)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.memberDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(Color.memberGold)
                        )
                } else {
                    Spacer().frame(height: 22)
                }
                
                Text(plan.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(white: 0.50))
                
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(plan.price)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isSelected ? .white : Color(white: 0.65))
                }
                
                Text(plan.per)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color(white: 0.70) : Color(white: 0.40))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.10) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                isSelected ? Color.memberGold.opacity(0.6) : Color.white.opacity(0.08),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - MEMBERSHIP DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MembershipDashboardView: View {
    @Binding var isMember: Bool
    @State private var selectedTab = 0
    
    private let pointsActivities: [PointsActivity] = [
        PointsActivity(title: "Purchase: Denim Jacket", date: "10 Mar 2026", points: "+90", isEarned: true),
        PointsActivity(title: "Redeemed: ₹200 off", date: "08 Mar 2026", points: "-200", isEarned: false),
        PointsActivity(title: "Purchase: Running Shoes", date: "05 Mar 2026", points: "+120", isEarned: true),
        PointsActivity(title: "Welcome Bonus", date: "01 Mar 2026", points: "+500", isEarned: true),
        PointsActivity(title: "Referral: Krishna2883", date: "28 Feb 2026", points: "+150", isEarned: true),
    ]
    
    private let appointments: [MemberAppointment] = [
        MemberAppointment(type: "Personal Styling", date: "15 Mar 2026", time: "2:00 PM", status: "Upcoming"),
        MemberAppointment(type: "Tailoring Consultation", date: "20 Mar 2026", time: "11:00 AM", status: "Confirmed"),
    ]
    
    private let tabs = ["Overview", "Points", "Appointments"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Membership card
                membershipCard
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                // Tab selector
                tabSelector
                    .padding(.top, 22)
                
                // Tab content
                Group {
                    switch selectedTab {
                    case 0: overviewTab
                    case 1: pointsTab
                    case 2: appointmentsTab
                    default: overviewTab
                    }
                }
                .padding(.top, 18)
                
                Spacer().frame(height: 30)
            }
        }
        .background(Color(red: 0.965, green: 0.965, blue: 0.965))
        .navigationTitle("Membership")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Membership Card
    private var membershipCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.memberDark,
                            Color(red: 0.14, green: 0.13, blue: 0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 190)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
            
            // Decorative rings
            Circle()
                .stroke(Color.memberGold.opacity(0.08), lineWidth: 1)
                .frame(width: 200, height: 200)
                .offset(x: 100, y: -40)
            
            Circle()
                .stroke(Color.memberGold.opacity(0.05), lineWidth: 1)
                .frame(width: 140, height: 140)
                .offset(x: 120, y: -20)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.memberGold)
                        Text("GOLD MEMBER")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.memberGold)
                    }
                    
                    Spacer()
                    
                    Text("Active")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.memberGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.memberGold.opacity(0.15))
                        )
                }
                
                Spacer()
                
                Text("Krishna Aaggarwal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer().frame(height: 4)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                        Text("670 Points")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.memberGold)
                    
                    Spacer()
                    
                    Text("Valid till Dec 2026")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.50))
                }
            }
            .padding(22)
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 6) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    Text(tab)
                        .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                        .foregroundColor(selectedTab == index ? .white : Color(white: 0.45))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == index ? Color.memberDark : Color.white)
                                .shadow(color: .black.opacity(selectedTab == index ? 0.08 : 0.02), radius: 6, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(spacing: 14) {
            // Quick stats
            HStack(spacing: 12) {
                statCard(value: "670", label: "Points", icon: "star.fill", color: .memberGold)
                statCard(value: "12", label: "Free Deliveries", icon: "shippingbox.fill", color: Color(red: 0.20, green: 0.72, blue: 0.45))
                statCard(value: "2", label: "Appointments", icon: "calendar", color: Color(red: 0.20, green: 0.45, blue: 0.80))
            }
            .padding(.horizontal, 20)
            
            // Benefits section
            VStack(alignment: .leading, spacing: 14) {
                Text("Your Benefits")
                    .font(.system(size: 17, weight: .bold))
                    .padding(.horizontal, 20)
                
                VStack(spacing: 0) {
                    overviewBenefitRow(icon: "shippingbox.fill", title: "Free Delivery", detail: "Unlimited on all orders", color: Color(red: 0.20, green: 0.72, blue: 0.45))
                    benefitDivider
                    overviewBenefitRow(icon: "calendar.badge.clock", title: "Book Appointments", detail: "Personal styling & tailoring", color: Color(red: 0.20, green: 0.45, blue: 0.80))
                    benefitDivider
                    overviewBenefitRow(icon: "star.circle.fill", title: "Points Rewards", detail: "Earn 1 point per ₹10 spent", color: .memberGold)
                    benefitDivider
                    overviewBenefitRow(icon: "tag.fill", title: "Exclusive Deals", detail: "Up to 30% off member pricing", color: Color(red: 0.90, green: 0.35, blue: 0.35))
                }
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(white: 0.93), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
            
            // Redeem banner
            redeemBanner
                .padding(.horizontal, 20)
                .padding(.top, 4)
        }
    }
    
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.50))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(white: 0.93), lineWidth: 1)
        )
    }
    
    private func overviewBenefitRow(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.50))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(white: 0.72))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
    
    private var benefitDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.10))
            .frame(height: 1)
            .padding(.leading, 68)
            .padding(.trailing, 16)
    }
    
    private var redeemBanner: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Redeem 100 Points")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.memberDark)
                Text("Get ₹200 off on your next order")
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.45))
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Redeem")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.memberDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(
                        Capsule().fill(Color.memberGold)
                    )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.memberGold.opacity(0.12), Color.memberGold.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.memberGold.opacity(0.25), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Points Tab
    private var pointsTab: some View {
        VStack(spacing: 14) {
            // Points balance card
            VStack(spacing: 6) {
                Text("Available Points")
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.50))
                Text("670")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundColor(.black)
                Text("= ₹1,340 value")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.memberGold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(white: 0.93), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            // Activity
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Activity")
                    .font(.system(size: 17, weight: .bold))
                    .padding(.horizontal, 20)
                
                VStack(spacing: 0) {
                    ForEach(Array(pointsActivities.enumerated()), id: \.element.id) { index, activity in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(activity.isEarned ? Color(red: 0.20, green: 0.72, blue: 0.45).opacity(0.12) : Color.red.opacity(0.10))
                                    .frame(width: 36, height: 36)
                                Image(systemName: activity.isEarned ? "arrow.down.left" : "arrow.up.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(activity.isEarned ? Color(red: 0.20, green: 0.72, blue: 0.45) : .red)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                                Text(activity.date)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(white: 0.55))
                            }
                            
                            Spacer()
                            
                            Text(activity.points)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(activity.isEarned ? Color(red: 0.20, green: 0.72, blue: 0.45) : .red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        
                        if index < pointsActivities.count - 1 {
                            Rectangle()
                                .fill(Color.gray.opacity(0.10))
                                .frame(height: 1)
                                .padding(.leading, 68)
                                .padding(.trailing, 16)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(white: 0.93), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Appointments Tab
    private var appointmentsTab: some View {
        VStack(spacing: 14) {
            // Upcoming appointments
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming")
                    .font(.system(size: 17, weight: .bold))
                    .padding(.horizontal, 20)
                
                ForEach(appointments) { apt in
                    appointmentCard(apt)
                }
            }
            
            // Book new
            Button(action: {}) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Book New Appointment")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.memberDark)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            
            // Available services
            VStack(alignment: .leading, spacing: 12) {
                Text("Available Services")
                    .font(.system(size: 17, weight: .bold))
                    .padding(.horizontal, 20)
                
                VStack(spacing: 0) {
                    serviceRow(icon: "scissors", title: "Personal Styling", time: "45 min", price: "Free")
                    serviceDivider
                    serviceRow(icon: "ruler", title: "Tailoring Consultation", time: "30 min", price: "Free")
                    serviceDivider
                    serviceRow(icon: "tshirt", title: "Wardrobe Review", time: "60 min", price: "₹299")
                    serviceDivider
                    serviceRow(icon: "camera", title: "Style Photoshoot", time: "90 min", price: "₹999")
                }
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(white: 0.93), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
            .padding(.top, 6)
        }
    }
    
    private func appointmentCard(_ apt: MemberAppointment) -> some View {
        HStack(spacing: 14) {
            // Date block
            VStack(spacing: 2) {
                Text(apt.date.components(separatedBy: " ").first ?? "15")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.memberDark)
                Text(apt.date.components(separatedBy: " ").dropFirst().first ?? "Mar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(white: 0.50))
            }
            .frame(width: 52, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.memberGold.opacity(0.12))
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(apt.type)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(apt.time)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Color(white: 0.50))
                }
            }
            
            Spacer()
            
            Text(apt.status)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.20, green: 0.72, blue: 0.45))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.20, green: 0.72, blue: 0.45).opacity(0.10))
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(white: 0.93), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func serviceRow(icon: String, title: String, time: String, price: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.memberDark)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.96))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                Text(time)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.50))
            }
            
            Spacer()
            
            Text(price)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(price == "Free" ? Color(red: 0.20, green: 0.72, blue: 0.45) : .black)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
    
    private var serviceDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.10))
            .frame(height: 1)
            .padding(.leading, 66)
            .padding(.trailing, 16)
    }
}

// MARK: - Preview
#Preview("Intro") {
    MembershipView()
}

#Preview("Dashboard") {
    NavigationStack {
        MembershipDashboardView(isMember: .constant(true))
    }
}
