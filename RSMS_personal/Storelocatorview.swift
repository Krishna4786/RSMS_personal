import SwiftUI

// MARK: - Store Model
struct StoreLocation: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: String
    let tags: [String]
    let hours: String
    let phone: String
    let rating: Double
}

// MARK: - Sort Option
enum StoreSortOption: String, CaseIterable {
    case nearest = "Nearest"
    case name = "A - Z"
}

// MARK: - Store Locator View
struct StoreLocatorView: View {
    @State private var searchText = ""
    @State private var sortOption: StoreSortOption = .nearest
    @State private var selectedStore: StoreLocation? = nil
    @State private var showStoreDetail = false
    
    private let stores: [StoreLocation] = [
        StoreLocation(name: "Indiranagar Flagship", address: "100 Feet Road, Indiranagar, Bengaluru 560038", distance: "0.8 km", tags: ["Pickup Available"], hours: "10:00 AM – 9:00 PM", phone: "+91 80 4567 1234", rating: 4.8),
        StoreLocation(name: "Koramangala Studio", address: "80 Feet Road, Koramangala, Bengaluru 560034", distance: "2.4 km", tags: ["Pickup Available", "Styling Studio"], hours: "10:00 AM – 9:30 PM", phone: "+91 80 4567 5678", rating: 4.6),
        StoreLocation(name: "UB City Boutique", address: "24 Vittal Mallya Rd, UB City, Bengaluru 560001", distance: "3.1 km", tags: ["Pickup Available"], hours: "11:00 AM – 10:00 PM", phone: "+91 80 4567 9012", rating: 4.9),
        StoreLocation(name: "Whitefield Concept", address: "Phoenix Marketcity, Whitefield, Bengaluru 560066", distance: "5.7 km", tags: ["Shipping Only"], hours: "10:00 AM – 9:00 PM", phone: "+91 80 4567 3456", rating: 4.4),
        StoreLocation(name: "JP Nagar Outlet", address: "15th Cross, JP Nagar Phase 2, Bengaluru 560078", distance: "7.2 km", tags: ["Pickup Available"], hours: "10:00 AM – 8:30 PM", phone: "+91 80 4567 7890", rating: 4.5),
    ]
    
    private var filteredStores: [StoreLocation] {
        let filtered = searchText.isEmpty ? stores : stores.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
        return sortOption == .name ? filtered.sorted { $0.name < $1.name } : filtered
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Sort + count
                HStack {
                    Text("\(filteredStores.count) stores nearby")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.50))
                    
                    Spacer()
                    
                    Menu {
                        ForEach(StoreSortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option { Image(systemName: "checkmark") }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(sortOption.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                
                // Store cards
                LazyVStack(spacing: 14) {
                    ForEach(filteredStores) { store in
                        storeCard(store)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Map card
                mapCard
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer().frame(height: 40)
            }
        }
        .background(Color(red: 0.965, green: 0.965, blue: 0.965))
        .navigationTitle("Find your Store")
        .navigationBarTitleDisplayMode(.large)
        .toolbarVisibility(.hidden, for: .tabBar)
        .sheet(isPresented: $showStoreDetail) {
            if let store = selectedStore {
                StoreDetailSheet(store: store)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.45))
            
            TextField("Search area or zip code", text: $searchText)
                .font(.system(size: 15))
            
            Button(action: {}) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(white: 0.92), lineWidth: 1)
        )
    }
    
    // MARK: - Store Card
    private func storeCard(_ store: StoreLocation) -> some View {
        Button {
            selectedStore = store
            showStoreDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Top section: distance + rating
                HStack {
                    // Distance badge
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(store.distance)
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(Color(white: 0.94))
                    )
                    
                    // Tags
                    ForEach(store.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(tag.contains("Pickup") ? Color(red: 0.20, green: 0.65, blue: 0.40) : Color(white: 0.50))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(
                                    tag.contains("Pickup")
                                    ? Color(red: 0.20, green: 0.65, blue: 0.40).opacity(0.08)
                                    : Color(white: 0.94)
                                )
                            )
                    }
                    
                    Spacer()
                    
                    // Rating
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 0.95, green: 0.75, blue: 0.25))
                        Text(String(format: "%.1f", store.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Store name
                Text(store.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                // Address
                Text(store.address)
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.45))
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                
                // Bottom row: hours + select button
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.50))
                        Text(store.hours)
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.50))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        Text("Select")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.black))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(white: 0.92), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Map Card
    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Map View")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Text("Explore all stores visually")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.50))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(.black))
                }
            }
            
            // Map placeholder
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(white: 0.93))
                .frame(height: 150)
                .overlay(
                    ZStack {
                        VStack(spacing: 18) {
                            ForEach(0..<5, id: \.self) { _ in
                                Rectangle().fill(Color(white: 0.88)).frame(height: 1)
                            }
                        }.padding(.horizontal, 12)
                        
                        HStack(spacing: 22) {
                            ForEach(0..<7, id: \.self) { _ in
                                Rectangle().fill(Color(white: 0.88)).frame(width: 1)
                            }
                        }.padding(.vertical, 12)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.black)
                            .offset(x: -25, y: -15)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(white: 0.55))
                            .offset(x: 35, y: 20)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(white: 0.65))
                            .offset(x: -50, y: 30)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(white: 0.88), lineWidth: 1)
                )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(white: 0.92), lineWidth: 1)
        )
    }
}

// MARK: - Store Detail Sheet
struct StoreDetailSheet: View {
    let store: StoreLocation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Store name
            Text(store.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 20)
            
            // Tags
            HStack(spacing: 8) {
                ForEach(store.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundColor(tag.contains("Pickup") ? Color(red: 0.20, green: 0.65, blue: 0.40) : Color(white: 0.50))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(
                                tag.contains("Pickup")
                                ? Color(red: 0.20, green: 0.65, blue: 0.40).opacity(0.10)
                                : Color(white: 0.94)
                            )
                        )
                }
            }
            .padding(.top, 10)
            
            // Details
            VStack(spacing: 0) {
                detailRow(icon: "mappin.and.ellipse", label: "Address", value: store.address)
                Divider().padding(.leading, 48)
                detailRow(icon: "clock", label: "Hours", value: store.hours)
                Divider().padding(.leading, 48)
                detailRow(icon: "phone", label: "Phone", value: store.phone)
                Divider().padding(.leading, 48)
                detailRow(icon: "location", label: "Distance", value: store.distance)
            }
            .padding(.top, 20)
            
            Spacer().frame(height: 24)
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "map")
                            .font(.system(size: 14, weight: .medium))
                        Text("Directions")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.black, lineWidth: 1.5)
                    )
                }
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Select Store")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.black)
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 22)
    }
    
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.40))
                .frame(width: 24)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(white: 0.50))
                    .tracking(0.5)
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        StoreLocatorView()
    }
}
