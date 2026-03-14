import SwiftUI

// MARK: - Saved Address Model
struct SavedAddress: Identifiable {
    let id = UUID()
    let label: String
    let address: String
    let isDefault: Bool
}

// MARK: - Payment Method
enum PaymentMethod: String, CaseIterable {
    case creditCard = "Credit Card"
    case applePay = "Apple Pay"
    case upi = "UPI"
    
    var icon: String {
        switch self {
        case .creditCard: return "creditcard"
        case .applePay: return "apple.logo"
        case .upi: return "indianrupeesign.circle"
        }
    }
}

// MARK: - Checkout View
struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPayment: PaymentMethod = .creditCard
    @State private var cardholderName = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var useSavedAddress = true
    @State private var selectedAddressIndex = 0
    @State private var showOrderConfirmation = false
    @State private var showStoreLocator = false
    
    // Store details - can be passed from StoreLocatorView
    @State private var selectedStoreName: String
    @State private var selectedStoreAddress: String
    
    private let savedAddresses: [SavedAddress] = [
        SavedAddress(label: "Home", address: "124 Savile Row, Indiranagar, Bengaluru 560038", isDefault: true),
        SavedAddress(label: "Office", address: "WeWork, Koramangala, Bengaluru 560034", isDefault: false),
    ]
    
    // Initialize with optional store details
    init(storeName: String = "Indiranagar Flagship", storeAddress: String = "100 Feet Road, Indiranagar") {
        _selectedStoreName = State(initialValue: storeName)
        _selectedStoreAddress = State(initialValue: storeAddress)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Step indicator
                Text("STEP 02")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(Color(white: 0.50))
                    .padding(.top, 8)
                
                Text("Payment Method")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(.black)
                    .padding(.top, 6)
                
                // Payment methods
                paymentMethodSelector
                    .padding(.top, 24)
                
                // Card form (shown for credit card)
                if selectedPayment == .creditCard {
                    cardForm
                        .padding(.top, 28)
                }
                
                // Billing address
                addressSection
                    .padding(.top, 32)
                
                // Selected store
                storeSection
                    .padding(.top, 28)
                
                // Order summary
                orderSummary
                    .padding(.top, 32)
                
                // Pay button
                Button {
                    showOrderConfirmation = true
                } label: {
                    Text("P A Y   N O W")
                        .font(.system(size: 15, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.black)
                        )
                }
                .padding(.top, 28)
                
                // Security note
                Text("SECURE ENCRYPTED TRANSACTION. BY CLICKING PAY NOW YOU AGREE TO OUR TERMS OF SERVICE.")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(Color(white: 0.55))
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity)
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(red: 0.975, green: 0.972, blue: 0.965))
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "bag")
                }
            }
        }
        .navigationDestination(isPresented: $showOrderConfirmation) {
            OrderConfirmationView()
        }
        .navigationDestination(isPresented: $showStoreLocator) {
            StoreLocatorView(onStoreSelected: { store in
                selectedStoreName = store.name
                selectedStoreAddress = store.address
                showStoreLocator = false
            })
        }
    }
    
    // MARK: - Payment Method Selector
    private var paymentMethodSelector: some View {
        VStack(spacing: 0) {
            ForEach(PaymentMethod.allCases, id: \.self) { method in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPayment = method
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: method.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 24)
                        
                        Text(method.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                            .tracking(0.5)
                        
                        if selectedPayment == method {
                            Circle()
                                .fill(.black)
                                .frame(width: 8, height: 8)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                
                if selectedPayment == method {
                    Rectangle()
                        .fill(.black)
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                } else {
                    Rectangle()
                        .fill(Color(white: 0.90))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(white: 0.90), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Card Form
    private var cardForm: some View {
        VStack(alignment: .leading, spacing: 22) {
            // Cardholder name
            VStack(alignment: .leading, spacing: 8) {
                Text("CARDHOLDER NAME")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.5)
                    .foregroundColor(Color(white: 0.45))
                
                TextField("Full name on card", text: $cardholderName)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
                Rectangle()
                    .fill(Color(white: 0.85))
                    .frame(height: 1)
            }
            
            // Card number
            VStack(alignment: .leading, spacing: 8) {
                Text("CARD NUMBER")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.5)
                    .foregroundColor(Color(white: 0.45))
                
                HStack {
                    TextField("0000 0000 0000 0000", text: $cardNumber)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(.black)
                        .keyboardType(.numberPad)
                    
                    Image(systemName: "lock.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(white: 0.70))
                }
                
                Rectangle()
                    .fill(Color(white: 0.85))
                    .frame(height: 1)
            }
            
            // Expiry + CVV row
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("EXPIRY DATE")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(Color(white: 0.45))
                    
                    TextField("MM / YY", text: $expiryDate)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .keyboardType(.numberPad)
                    
                    Rectangle()
                        .fill(Color(white: 0.85))
                        .frame(height: 1)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("CVV")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(Color(white: 0.45))
                    
                    SecureField("•••", text: $cvv)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .keyboardType(.numberPad)
                    
                    Rectangle()
                        .fill(Color(white: 0.85))
                        .frame(height: 1)
                }
                .frame(width: 80)
            }
        }
    }
    
    // MARK: - Address Section
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("BILLING ADDRESS")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(Color(white: 0.45))
            
            // Saved addresses
            ForEach(Array(savedAddresses.enumerated()), id: \.element.id) { index, addr in
                Button {
                    selectedAddressIndex = index
                    useSavedAddress = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(useSavedAddress && selectedAddressIndex == index ? Color.black : Color(white: 0.75), lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                            
                            if useSavedAddress && selectedAddressIndex == index {
                                Circle()
                                    .fill(.black)
                                    .frame(width: 12, height: 12)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(addr.label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                if addr.isDefault {
                                    Text("DEFAULT")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1)
                                        .foregroundColor(Color(white: 0.50))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule().fill(Color(white: 0.93))
                                        )
                                }
                            }
                            
                            Text(addr.address)
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.45))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        useSavedAddress && selectedAddressIndex == index ? Color.black : Color(white: 0.90),
                                        lineWidth: useSavedAddress && selectedAddressIndex == index ? 1.5 : 1
                                    )
                            )
                    )
                }
            }
            
            // Add new address
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16))
                    Text("Add new address")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.black)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Store Section
    private var storeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PICKUP STORE")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(Color(white: 0.45))
            
            HStack(spacing: 14) {
                Image(systemName: "storefront")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .frame(width: 42, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(white: 0.94))
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedStoreName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    Text(selectedStoreAddress)
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.45))
                }
                
                Spacer()
                
                Button {
                    showStoreLocator = true
                } label: {
                    Text("Change")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .underline()
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(white: 0.90), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Order Summary
    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("REVIEW")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(Color(white: 0.45))
            
            Text("Order Summary")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .italic()
                .foregroundColor(.black)
                .padding(.top, 6)
            
            // Product
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(white: 0.93))
                    .frame(width: 70, height: 80)
                    .overlay(
                        Image(systemName: "tshirt.fill")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.gray.opacity(0.4))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Signature Wool Overcoat")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    Text("CHARCOAL / SIZE 48")
                        .font(.system(size: 11, weight: .medium))
                        .tracking(0.8)
                        .foregroundColor(Color(white: 0.50))
                }
                
                Spacer()
                
                Text("₹1,280.00")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
            }
            .padding(.top, 18)
            
            // Totals
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(white: 0.88))
                    .frame(height: 1)
                    .padding(.vertical, 16)
                
                summaryRow(label: "SUBTOTAL", value: "₹1,280.00")
                summaryRow(label: "SHIPPING", value: "₹45.00")
                summaryRow(label: "TAX (GST)", value: "₹89.80")
                
                Rectangle()
                    .fill(Color(white: 0.88))
                    .frame(height: 1)
                    .padding(.vertical, 12)
                
                HStack {
                    Text("Total")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .italic()
                        .foregroundColor(.black)
                    Spacer()
                    Text("₹1,414.80")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(white: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(white: 0.90), lineWidth: 1)
                )
        )
    }
    
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .tracking(1)
                .foregroundColor(Color(white: 0.45))
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.black)
        }
        .padding(.vertical, 6)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - ORDER CONFIRMATION VIEW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct OrderConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToHome = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Success header
                Text("SUCCESS")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(Color(red: 0.20, green: 0.65, blue: 0.40))
                    .padding(.top, 12)
                
                Text("Thank you\nfor your\norder.")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .lineSpacing(4)
                    .padding(.top, 8)
                
                // Order reference
                VStack(alignment: .leading, spacing: 3) {
                    Text("Order Reference")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.50))
                    Text("#LX-99283")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .italic()
                        .foregroundColor(.black)
                }
                .padding(.top, 16)
                
                // Store location card
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(white: 0.90))
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 44, weight: .light))
                                .foregroundColor(Color(white: 0.75))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LOCATION")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Indiranagar Flagship")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.55))
                    )
                    .padding(12)
                }
                .padding(.top, 20)
                
                // Pickup info
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        Spacer().frame(width: 0)
                    }
                    
                    Text("Your items will be ready at Indiranagar Flagship in 2 hours.")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .lineSpacing(4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("ESTIMATED PICKUP")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(1)
                                .foregroundColor(Color(white: 0.50))
                            Text("Today, 4:30 PM — 7:00 PM")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, 24)
                
                // QR Code
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white)
                        .frame(height: 140)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 60))
                                    .foregroundColor(.black)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(white: 0.88), lineWidth: 1)
                        )
                    
                    Text("SCANNER ID FOR PICKUP")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(Color(white: 0.50))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                
                // Order summary
                confirmationSummary
                    .padding(.top, 32)
                
                // Footer note
                Text("A confirmation email has been sent to your registered address. Please present the QR code upon arrival.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                
                // Continue shopping
                Button(action: {
                    navigateToHome = true
                }) {
                    HStack(spacing: 8) {
                        Text("C O N T I N U E   S H O P P I N G")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(2)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.black, lineWidth: 1.5)
                    )
                }
                .padding(.top, 16)
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(red: 0.975, green: 0.972, blue: 0.965))
        .navigationTitle("Order Confirmed")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navigateToHome = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Home")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.black)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "bag")
                        .foregroundColor(.black)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToHome) {
            StoreMHomeView()
        }
    }
    
    // MARK: - Confirmation Summary
    private var confirmationSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Order Summary")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Spacer()
                Text("3 Items")
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.50))
            }
            
            // Items
            VStack(spacing: 14) {
                confirmationItem(name: "Heavyweight Cotton Crewneck", variant: "CHARCOAL / SIZE M", price: "₹120.00")
                confirmationItem(name: "Pleated Wool Trousers", variant: "SAND / SIZE 32", price: "₹340.00")
            }
            .padding(.top, 18)
            
            // Totals
            Rectangle()
                .fill(Color(white: 0.88))
                .frame(height: 1)
                .padding(.vertical, 16)
            
            totalRow(label: "SUBTOTAL", value: "₹460.00")
            totalRow(label: "TAXES", value: "₹38.40")
            
            Rectangle()
                .fill(Color(white: 0.88))
                .frame(height: 1)
                .padding(.vertical, 12)
            
            HStack {
                Text("Total")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Spacer()
                Text("₹498.40")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
    
    private func confirmationItem(name: String, variant: String, price: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.93))
                .frame(width: 56, height: 64)
                .overlay(
                    Image(systemName: "tshirt.fill")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.gray.opacity(0.4))
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                Text(variant)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.8)
                    .foregroundColor(Color(white: 0.50))
            }
            
            Spacer()
            
            Text(price)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    private func totalRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .tracking(1)
                .foregroundColor(Color(white: 0.45))
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.black)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews
#Preview("Checkout") {
    NavigationStack {
        CheckoutView()
    }
}

#Preview("Confirmation") {
    NavigationStack {
        OrderConfirmationView()
    }
}
