//
//  ProfileView.swift
//  RSMSApp
//
//  Created by Utkarsh Dubey on 09/03/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - User Info
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.storePrimary.opacity(0.1), Color.storePrimary.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color.storePrimary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Martin Butler")
                            .font(.system(size: 20, weight: .bold))
                        Text("martin.butler@example.com")
                            .font(.system(size: 14))
                            .foregroundColor(.storeTextSecondary)
                    }
                    
                    Button(action: {}) {
                        Text("Edit Profile")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.storePrimary)
                            .cornerRadius(20)
                    }
                }
                .padding(.top, 20)
                
                // MARK: - Profile Options
                VStack(spacing: 0) {
                    NavigationLink(destination: MyOrdersView()) {
                        ProfileOptionRow(icon: "bag", title: "My Orders", color: .blue)
                    }
                    Divider().padding(.leading, 56)
                    ProfileOptionRow(icon: "heart", title: "Wishlist", color: .red)
                    Divider().padding(.leading, 56)
                    ProfileOptionRow(icon: "creditcard", title: "Payment Methods", color: .green)
                    Divider().padding(.leading, 56)
                    ProfileOptionRow(icon: "mappin.and.ellipse", title: "Delivery Address", color: .orange)
                    Divider().padding(.leading, 56)
                    ProfileOptionRow(icon: "bell", title: "Notifications", color: .purple)
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                // MARK: - Support & Settings
                VStack(spacing: 0) {
                    NavigationLink(destination: SupportSystemView()) {
                        ProfileOptionRow(icon: "questionmark.circle", title: "Help & Support", color: .gray)
                    }
                    Divider().padding(.leading, 56)
                    ProfileOptionRow(icon: "gearshape", title: "Settings", color: .gray)
                    Divider().padding(.leading, 56)
                    ProfileOptionRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", color: .red, isDestructive: true)
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 30)
        }
        .background(Color.storeBackground)
        .navigationTitle("Profile")
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDestructive ? Color.red.opacity(0.1) : color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDestructive ? .red : color)
            }
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(isDestructive ? .red : .storeTextPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileView()
}
