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
        case .all:       return .primary
        case .received:  return Color(red: 0.10, green: 0.10, blue: 0.16)
        case .shipped:   return Color(red: 0.88, green: 0.48, blue: 0.05)
        case .delivered:  return Color(red: 0.13, green: 0.62, blue: 0.38)
        case .cancelled:  return Color(red: 0.85, green: 0.22, blue: 0.22)
        }
    }

    var icon: String {
        switch self {
        case .all:        return "list.bullet"
        case .received:   return "shippingbox.fill"
        case .shipped:    return "box.truck.fill"
        case .delivered:   return "checkmark.circle.fill"
        case .cancelled:   return "xmark.circle.fill"
        }
    }
}

// MARK: - Order Model
struct Order: Identifiable {
    let id = UUID()
    let orderNumber: String
    let date: String
    let parsedDate: Date
    let productName: String
    let size: String
    let price: String
    let quantity: Int
    let estimateTotal: String
    let status: OrderStatus
    let imageName: String
}

// MARK: - Date Helper
private let orderDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd MMM yyyy"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
}()

private func parseDate(_ string: String) -> Date {
    orderDateFormatter.date(from: string) ?? .now
}

// MARK: - My Orders View
struct MyOrdersView: View {
    @State private var selectedFilter: OrderStatus = .all
    @State private var showDateFilter = false
    @State private var fromDate: Date = Calendar.current.date(byAdding: .month, value: -3, to: .now) ?? .now
    @State private var toDate: Date = .now
    @State private var isDateFilterActive = false

    private let orders: [Order] = [
        Order(orderNumber: "ORD-2026-001", date: "10 Mar 2026", parsedDate: parseDate("10 Mar 2026"),
              productName: "Tape Winter Coat", size: "M", price: "Rs.235,000",
              quantity: 2, estimateTotal: "Rs.470,000", status: .received, imageName: "coat1"),
        Order(orderNumber: "ORD-2026-002", date: "08 Mar 2026", parsedDate: parseDate("08 Mar 2026"),
              productName: "Denim Jacket", size: "L", price: "Rs.89,000",
              quantity: 1, estimateTotal: "Rs.89,000", status: .shipped, imageName: "jacket1"),
        Order(orderNumber: "ORD-2026-003", date: "05 Mar 2026", parsedDate: parseDate("05 Mar 2026"),
              productName: "Classic T-Shirt", size: "S", price: "Rs.29,000",
              quantity: 3, estimateTotal: "Rs.87,000", status: .delivered, imageName: "tshirt1"),
        Order(orderNumber: "ORD-2026-004", date: "01 Mar 2026", parsedDate: parseDate("01 Mar 2026"),
              productName: "Running Shoes", size: "42", price: "Rs.119,000",
              quantity: 1, estimateTotal: "Rs.119,000", status: .delivered, imageName: "shoes1"),
        Order(orderNumber: "ORD-2026-005", date: "25 Feb 2026", parsedDate: parseDate("25 Feb 2026"),
              productName: "Wool Scarf", size: "One Size", price: "Rs.34,000",
              quantity: 1, estimateTotal: "Rs.34,000", status: .cancelled, imageName: "scarf1"),
        Order(orderNumber: "ORD-2026-006", date: "20 Feb 2026", parsedDate: parseDate("20 Feb 2026"),
              productName: "Tape Winter Coat", size: "M", price: "Rs.235,000",
              quantity: 2, estimateTotal: "Rs.470,000", status: .received, imageName: "coat2"),
    ]

    private var filteredOrders: [Order] {
        var result = orders

        // Status filter
        if selectedFilter != .all {
            result = result.filter { $0.status == selectedFilter }
        }

        // Date range filter
        if isDateFilterActive {
            let startOfFrom = Calendar.current.startOfDay(for: fromDate)
            let endOfTo = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: toDate)) ?? toDate
            result = result.filter { $0.parsedDate >= startOfFrom && $0.parsedDate < endOfTo }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar: Filters + Date Button
            VStack(spacing: 10) {
                // Status filter chips
                filterChips

                // Date range row
                dateFilterBar
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))

            Divider()

            // MARK: - Order Summary Strip
            orderSummaryStrip
                .padding(.top, 14)
                .padding(.bottom, 6)

            // MARK: - Order List
            ScrollView(.vertical, showsIndicators: false) {
                if filteredOrders.isEmpty {
                    emptyState
                        .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredOrders) { order in
                            NavigationLink(destination: OrderTrackingView()) {
                                orderCard(order: order)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showDateFilter) {
            dateFilterSheet
        }
    }

    // MARK: - Order Summary Strip
    private var orderSummaryStrip: some View {
        HStack(spacing: 0) {
            summaryItem(count: filteredOrders.filter { $0.status == .received }.count,
                        total: orders.filter { $0.status == .received }.count,
                        label: "Active",
                        icon: "shippingbox.fill",
                        color: Color(red: 0.10, green: 0.10, blue: 0.16))

            Divider().frame(height: 40)

            summaryItem(count: filteredOrders.filter { $0.status == .delivered }.count,
                        total: orders.filter { $0.status == .delivered }.count,
                        label: "Completed",
                        icon: "checkmark.circle.fill",
                        color: Color(red: 0.13, green: 0.62, blue: 0.38))

            Divider().frame(height: 40)

            summaryItem(count: filteredOrders.filter { $0.status == .cancelled }.count,
                        total: orders.filter { $0.status == .cancelled }.count,
                        label: "Cancelled",
                        icon: "xmark.circle.fill",
                        color: Color(red: 0.85, green: 0.22, blue: 0.22))
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func summaryItem(count: Int, total: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            Text("\(count)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
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
                        HStack(spacing: 5) {
                            if selectedFilter == status {
                                Image(systemName: status.icon)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            Text(status.rawValue)
                                .font(.system(size: 13, weight: selectedFilter == status ? .bold : .medium))
                        }
                        .foregroundColor(selectedFilter == status ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedFilter == status
                                      ? Color(red: 0.10, green: 0.10, blue: 0.16)
                                      : Color(.systemBackground))
                                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedFilter == status
                                        ? Color.clear
                                        : Color(.separator).opacity(0.4), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Date Filter Bar
    private var dateFilterBar: some View {
        HStack(spacing: 10) {
            Button {
                showDateFilter = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .semibold))
                    if isDateFilterActive {
                        Text("\(fromDate, format: .dateTime.day().month(.abbreviated)) – \(toDate, format: .dateTime.day().month(.abbreviated))")
                            .font(.system(size: 13, weight: .semibold))
                    } else {
                        Text("Filter by Date")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(isDateFilterActive ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isDateFilterActive
                              ? Color(red: 0.10, green: 0.10, blue: 0.16)
                              : Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                )
                .overlay(
                    Capsule()
                        .stroke(isDateFilterActive
                                ? Color.clear
                                : Color(.separator).opacity(0.4), lineWidth: 1)
                )
            }

            if isDateFilterActive {
                Button {
                    withAnimation {
                        isDateFilterActive = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Date Filter Sheet
    private var dateFilterSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("From")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    DatePicker("From Date", selection: $fromDate, in: ...toDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.tertiarySystemBackground))
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("To")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    DatePicker("To Date", selection: $toDate, in: fromDate...Date.now, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.tertiarySystemBackground))
                        )
                }

                // Quick presets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Select")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        datePresetButton("Last 7 days", days: 7)
                        datePresetButton("Last 30 days", days: 30)
                        datePresetButton("Last 90 days", days: 90)
                    }
                }

                Spacer()

                // Apply button
                Button {
                    withAnimation {
                        isDateFilterActive = true
                        showDateFilter = false
                    }
                } label: {
                    Text("Apply Filter")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(red: 0.10, green: 0.10, blue: 0.16))
                        )
                }
            }
            .padding(24)
            .navigationTitle("Select Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showDateFilter = false
                    }
                }
                if isDateFilterActive {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear") {
                            withAnimation {
                                isDateFilterActive = false
                                showDateFilter = false
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func datePresetButton(_ title: String, days: Int) -> some View {
        Button {
            fromDate = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
            toDate = .now
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Order Card (Improved Visibility)
    private func orderCard(order: Order) -> some View {
        VStack(spacing: 0) {
            // Product row
            HStack(spacing: 14) {
                // Product image placeholder — higher contrast
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: productIcon(for: order.productName))
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.6))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(order.productName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text("Size: \(order.size)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(alignment: .firstTextBaseline) {
                        Text(order.price)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()

                        Text("×\(order.quantity)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)

            // Divider
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 16)

            // Bottom row: Estimate Total + Status
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Estimate Total")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(order.estimateTotal)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

                Spacer()

                // Status badge — stronger visibility
                HStack(spacing: 5) {
                    Circle()
                        .fill(order.status.color)
                        .frame(width: 7, height: 7)
                    Text(order.status.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(order.status.color)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(order.status.color.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(order.status.color.opacity(0.35), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider
            Rectangle()
                .fill(Color(.separator).opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 16)

            // Date footer
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .medium))
                    Text(order.date)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Text("Track Order")
                        .font(.system(size: 13, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Color(red: 0.10, green: 0.10, blue: 0.16))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 14, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
        )
    }

    // Product-specific icons
    private func productIcon(for name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("coat") || lower.contains("jacket") { return "jacket.fill" }
        if lower.contains("shirt") || lower.contains("tee")    { return "tshirt.fill" }
        if lower.contains("shoe") || lower.contains("running") { return "shoe.fill" }
        if lower.contains("scarf")                              { return "scarf.fill" }
        return "bag.fill"
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 52, weight: .thin))
                .foregroundColor(.secondary.opacity(0.4))

            Text("No orders found")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text("Try adjusting your filters or date range.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if isDateFilterActive {
                Button {
                    withAnimation {
                        isDateFilterActive = false
                        selectedFilter = .all
                    }
                } label: {
                    Text("Clear All Filters")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.10, green: 0.10, blue: 0.16))
                        )
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Placeholder for navigation destination
struct MyOrderTrackingView: View {
    var body: some View {
        Text("Order Tracking")
            .navigationTitle("Track Order")
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MyOrdersView()
    }
}
