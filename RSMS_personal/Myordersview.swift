import SwiftUI

// MARK: - Order Status
enum OrderStatus: String, CaseIterable {
    case all = "All"
    case received = "Order Received"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .all: return .black
        case .received: return Color(red: 0.12, green: 0.13, blue: 0.18)
        case .shipped: return Color(red: 0.95, green: 0.55, blue: 0.10)
        case .delivered: return Color(red: 0.20, green: 0.72, blue: 0.45)
        case .cancelled: return Color(red: 0.90, green: 0.30, blue: 0.30)
        }
    }
}

// MARK: - Order Model
struct Order: Identifiable {
    let id = UUID()
    let orderNumber: String
    let date: String
    let productName: String
    let size: String
    let price: String
    let quantity: Int
    let estimateTotal: String
    let status: OrderStatus
    let imageName: String
}

// MARK: - My Orders View
struct MyOrdersView: View {
    @State private var selectedFilter: OrderStatus = .all
    
    private let orders: [Order] = [
        Order(orderNumber: "ORD-2026-001", date: "10 Mar 2026", productName: "Tape Winter Coat", size: "M", price: "Rs.235,000", quantity: 2, estimateTotal: "Rs.470,000", status: .received, imageName: "coat1"),
        Order(orderNumber: "ORD-2026-002", date: "08 Mar 2026", productName: "Denim Jacket", size: "L", price: "Rs.89,000", quantity: 1, estimateTotal: "Rs.89,000", status: .shipped, imageName: "jacket1"),
        Order(orderNumber: "ORD-2026-003", date: "05 Mar 2026", productName: "Classic T-Shirt", size: "S", price: "Rs.29,000", quantity: 3, estimateTotal: "Rs.87,000", status: .delivered, imageName: "tshirt1"),
        Order(orderNumber: "ORD-2026-004", date: "01 Mar 2026", productName: "Running Shoes", size: "42", price: "Rs.119,000", quantity: 1, estimateTotal: "Rs.119,000", status: .delivered, imageName: "shoes1"),
        Order(orderNumber: "ORD-2026-005", date: "25 Feb 2026", productName: "Wool Scarf", size: "One Size", price: "Rs.34,000", quantity: 1, estimateTotal: "Rs.34,000", status: .cancelled, imageName: "scarf1"),
        Order(orderNumber: "ORD-2026-006", date: "20 Feb 2026", productName: "Tape Winter Coat", size: "M", price: "Rs.235,000", quantity: 2, estimateTotal: "Rs.470,000", status: .received, imageName: "coat2"),
    ]
    
    private var filteredOrders: [Order] {
        if selectedFilter == .all {
            return orders
        }
        return orders.filter { $0.status == selectedFilter }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky filter chips
            filterChips
                .padding(.top, 8)
                .padding(.bottom, 10)
                .background(Color(red: 0.965, green: 0.965, blue: 0.965))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Order cards
                    if filteredOrders.isEmpty {
                        emptyState
                            .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredOrders) { order in
                                NavigationLink(destination: OrderTrackingView()) {
                                    orderCard(order: order)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                    }
                    
                    Spacer().frame(height: 30)
                }
            }
        }
        .background(Color(red: 0.965, green: 0.965, blue: 0.965))
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Order Summary Strip
    private var orderSummaryStrip: some View {
        HStack(spacing: 0) {
            summaryItem(count: orders.filter { $0.status == .received }.count, label: "Active", color: Color(red: 0.12, green: 0.13, blue: 0.18))
            
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 1, height: 36)
            
            summaryItem(count: orders.filter { $0.status == .delivered }.count, label: "Completed", color: Color(red: 0.20, green: 0.72, blue: 0.45))
            
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 1, height: 36)
            
            summaryItem(count: orders.filter { $0.status == .cancelled }.count, label: "Cancelled", color: Color(red: 0.90, green: 0.30, blue: 0.30))
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
        )
        .padding(.horizontal, 20)
    }
    
    private func summaryItem(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OrderStatus.allCases, id: \.self) { status in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = status
                        }
                    } label: {
                        Text(status.rawValue)
                            .font(.system(size: 13, weight: selectedFilter == status ? .semibold : .medium))
                            .foregroundColor(selectedFilter == status ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == status ? Color(red: 0.12, green: 0.13, blue: 0.18) : .white)
                                    .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Order Card
    private func orderCard(order: Order) -> some View {
        VStack(spacing: 0) {
            // Product row
            HStack(spacing: 14) {
                // Product image placeholder
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.95, green: 0.95, blue: 0.96))
                    .frame(width: 76, height: 76)
                    .overlay(
                        Image(systemName: "tshirt.fill")
                            .font(.system(size: 26, weight: .light))
                            .foregroundColor(.gray.opacity(0.4))
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(order.productName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Size : \(order.size)")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.55))
                    
                    HStack {
                        Text(order.price)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("x\(order.quantity)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(white: 0.55))
                    }
                }
            }
            .padding(16)
            
            // Divider — stronger visibility
            Rectangle()
                .fill(Color.gray.opacity(0.18))
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // Bottom row: Estimate Total + Status
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Estimate Total")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.55))
                    Text(order.estimateTotal)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Status badge
                Text(order.status.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(order.status.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(order.status.color.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(order.status.color.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            // Second divider
            Rectangle()
                .fill(Color.gray.opacity(0.12))
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // Date footer
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.55))
                Text(order.date)
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.55))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Track Order")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.12, green: 0.13, blue: 0.18))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.13, blue: 0.18))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(white: 0.92), lineWidth: 1)
        )
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bag")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No orders found")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
            
            Text("Orders with this status will appear here.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MyOrdersView()
    }
}
