import SwiftUI

// MARK: - Notification Model
struct AppNotification: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let subtitle: String
    let time: String
    let isUnread: Bool
}

// MARK: - Notifications View
struct NotificationsView: View {
    @State private var notifications: [AppNotification] = [
        AppNotification(icon: "bag.fill", iconColor: Color(red: 0.30, green: 0.55, blue: 0.85), iconBg: Color(red: 0.30, green: 0.55, blue: 0.85).opacity(0.12), title: "New Order Placed", subtitle: "2X H&M T-Shirt", time: "2 min ago", isUnread: true),
        AppNotification(icon: "shippingbox.fill", iconColor: Color(red: 0.95, green: 0.65, blue: 0.20), iconBg: Color(red: 0.95, green: 0.65, blue: 0.20).opacity(0.12), title: "Order Shipped", subtitle: "Denim Jacket is on its way", time: "1 hr ago", isUnread: true),
        AppNotification(icon: "checkmark.circle.fill", iconColor: Color(red: 0.20, green: 0.72, blue: 0.45), iconBg: Color(red: 0.20, green: 0.72, blue: 0.45).opacity(0.12), title: "Order Delivered", subtitle: "Running Shoes delivered successfully", time: "3 hr ago", isUnread: false),
        AppNotification(icon: "tag.fill", iconColor: Color(red: 0.85, green: 0.35, blue: 0.35), iconBg: Color(red: 0.85, green: 0.35, blue: 0.35).opacity(0.12), title: "Flash Sale Live!", subtitle: "Up to 50% off on winter collection", time: "5 hr ago", isUnread: false),
        AppNotification(icon: "star.fill", iconColor: Color(red: 0.95, green: 0.75, blue: 0.25), iconBg: Color(red: 0.95, green: 0.75, blue: 0.25).opacity(0.12), title: "Points Earned", subtitle: "+90 points from your last purchase", time: "Yesterday", isUnread: false),
        AppNotification(icon: "person.badge.plus", iconColor: Color(red: 0.45, green: 0.40, blue: 0.80), iconBg: Color(red: 0.45, green: 0.40, blue: 0.80).opacity(0.12), title: "Welcome to Premium!", subtitle: "Your membership is now active", time: "2 days ago", isUnread: false),
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                // Unread section
                let unread = notifications.filter { $0.isUnread }
                let read = notifications.filter { !$0.isUnread }
                
                if !unread.isEmpty {
                    sectionLabel("New")
                    
                    ForEach(unread) { notification in
                        notificationCard(notification)
                            .transition(.asymmetric(
                                insertion: .slide.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                
                if !read.isEmpty {
                    sectionLabel("Earlier")
                        .padding(.top, unread.isEmpty ? 0 : 8)
                    
                    ForEach(read) { notification in
                        notificationCard(notification)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear All") {}
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
    }
    
    // MARK: - Section Label
    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(white: 0.45))
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
    }
    
    // MARK: - Notification Card
    private func notificationCard(_ notification: AppNotification) -> some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.iconBg)
                    .frame(width: 44, height: 44)
                
                Image(systemName: notification.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(notification.iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    
                    if notification.isUnread {
                        Circle()
                            .fill(Color(red: 0.30, green: 0.55, blue: 0.85))
                            .frame(width: 7, height: 7)
                    }
                }
                
                Text(notification.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.50))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Time
            Text(notification.time)
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.60))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation {
                    notifications.removeAll { $0.id == notification.id }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        NotificationsView()
    }
}
