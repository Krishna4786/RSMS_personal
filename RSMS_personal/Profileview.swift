import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Profile header
                profileHeader
                    .padding(.top, 12)
                
                // Terms & Condition section
                sectionHeader("Terms & Condition")
                    .padding(.top, 28)
                
                settingsGroup {
                    settingsRow(icon: "creditcard", title: "Payment", iconBg: Color(red: 0.12, green: 0.13, blue: 0.18))
                    settingsDivider
                    settingsRow(icon: "tag", title: "Promo", iconBg: Color(red: 0.95, green: 0.55, blue: 0.10))
                    settingsDivider
                    settingsRow(icon: "globe", title: "Language", iconBg: Color(red: 0.20, green: 0.45, blue: 0.80))
                    settingsDivider
                    settingsRow(icon: "questionmark.circle", title: "Support", iconBg: Color(red: 0.55, green: 0.55, blue: 0.58))
                }
                .padding(.top, 10)
                
                // Accounts & Subscription section
                sectionHeader("Accounts & Subscription")
                    .padding(.top, 28)
                
                settingsGroup {
                    toggleRow(icon: "bell.badge", title: "Notification", iconBg: Color(red: 0.20, green: 0.72, blue: 0.45), isOn: $notificationsEnabled)
                    settingsDivider
                    toggleRow(icon: "moon", title: "Dark Mode", iconBg: Color(red: 0.45, green: 0.35, blue: 0.75), isOn: $darkModeEnabled)
                    settingsDivider
                    settingsRow(icon: "externaldrive", title: "My Data", iconBg: Color(red: 0.30, green: 0.65, blue: 0.80))
                    settingsDivider
                    settingsRow(icon: "shield.checkered", title: "Privacy", iconBg: Color(red: 0.55, green: 0.55, blue: 0.58))
                }
                .padding(.top, 10)
                
                // Danger zone
                logoutButton
                    .padding(.top, 28)
                
                // App version
                Text("Store.M v1.0.0")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.72))
                    .padding(.top, 20)
                
                Spacer().frame(height: 30)
            }
        }
        .background(Color(red: 0.965, green: 0.965, blue: 0.965))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.82), Color(white: 0.90)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Krishna Aaggarwal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Text("Krishna2883")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.55))
            }
            
            Spacer()
            
            // Edit profile button
            Button(action: {}) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            }
        }
        .padding(18)
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
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 22)
    }
    
    // MARK: - Settings Group Container
    private func settingsGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.vertical, 4)
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
    }
    
    // MARK: - Settings Row (with chevron)
    private func settingsRow(icon: String, title: String, iconBg: Color) -> some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(iconBg)
                    )
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(white: 0.72))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
    }
    
    // MARK: - Toggle Row
    private func toggleRow(icon: String, title: String, iconBg: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconBg)
                )
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(red: 0.20, green: 0.72, blue: 0.45))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
    
    // MARK: - Divider
    private var settingsDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.12))
            .frame(height: 1)
            .padding(.leading, 66)
            .padding(.trailing, 16)
    }
    
    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .medium))
                Text("Log Out")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.90, green: 0.25, blue: 0.25))
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView()
    }
}
