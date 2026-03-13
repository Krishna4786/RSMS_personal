import SwiftUI

// MARK: - Tracking Status
enum TrackingStatus: Int, CaseIterable {
    case received = 0
    case inTransit = 1
    case delivered = 2
    
    var label: String {
        switch self {
        case .received: return "Received"
        case .inTransit: return "In Transit"
        case .delivered: return "Delivered"
        }
    }
}

// MARK: - Timeline Entry
struct TimelineEntry: Identifiable {
    let id = UUID()
    let time: String
    let date: String
    let description: String
    let isCompleted: Bool
}

// MARK: - Main View
struct OrderTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let currentStatus: TrackingStatus = .inTransit
    
    private let timelineEntries: [TimelineEntry] = [
        TimelineEntry(time: "9:30am", date: "11 jan", description: "fjwentjew wk ds hs hdw uyh , hyi b idwe cuweiuceuwfweufnwufniwebfuew uwef", isCompleted: true),
        TimelineEntry(time: "9:30am", date: "11 jan", description: "fjwentjew wk ds hs hdw uyh , hyi b idwe cuweiuceuwfweufnwufniwebfuew uwef", isCompleted: true),
        TimelineEntry(time: "9:30am", date: "11 jan", description: "fjwentjew wk ds hs hdw uyh , hyi b idwe cuweiuceuwfweufnwufniwebfuew uwef", isCompleted: true)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Tracking ID
                trackingIDSection
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                // Progress tracker
                progressTracker
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                // Track Shipping button
                Button(action: {}) {
                    Text("Track Shipping")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                
                // Delivery Details
                deliveryDetailsSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                // Contact Rider
                contactRiderSection
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Timeline
                timelineSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                Spacer().frame(height: 40)
            }
        }
        .background(Color.white)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "bell")
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
    }
    
    // MARK: - Tracking ID
    private var trackingIDSection: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color(red: 0.12, green: 0.12, blue: 0.14))
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Tracking ID")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                Text("PAQ-327-P21")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("In Transit")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Progress Tracker
    private var progressTracker: some View {
        VStack(spacing: 0) {
            // Progress bar with dots
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let stepWidth = totalWidth / 2
                let progressFraction: CGFloat = CGFloat(currentStatus.rawValue) / 2.0
                
                ZStack(alignment: .leading) {
                    // Background line
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.92, green: 0.92, blue: 0.93))
                        .frame(height: 4)
                    
                    // Filled line
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black)
                        .frame(width: totalWidth * progressFraction, height: 4)
                    
                    // Dots
                    ForEach(0..<3) { index in
                        let xPos = stepWidth * CGFloat(index)
                        let isActive = index <= currentStatus.rawValue
                        let isCurrent = index == currentStatus.rawValue
                        
                        Circle()
                            .fill(isActive ? Color.black : Color(red: 0.85, green: 0.85, blue: 0.86))
                            .frame(width: isCurrent ? 20 : 14, height: isCurrent ? 20 : 14)
                            .overlay(
                                Group {
                                    if isActive && index < currentStatus.rawValue {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                            .position(x: xPos, y: 10)
                    }
                }
                .frame(height: 20)
            }
            .frame(height: 20)
            
            Spacer().frame(height: 10)
            
            // Labels
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Received")
                        .font(.system(size: 12, weight: .semibold))
                    Text("10:30 pm")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("In Transit")
                        .font(.system(size: 12, weight: .semibold))
                    Text("10:30 pm")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Delivered")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("10:30 pm")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Delivery Details
    private var deliveryDetailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Delivery Details")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .padding(.bottom, 16)
            
            detailRow(label: "Receiver", value: "Jhon Doe")
            detailDivider
            detailRow(label: "Address", value: "12, Palm Grace")
            detailDivider
            detailRow(label: "Contact", value: "+234-123-123-432")
            detailDivider
            detailRow(label: "Item", value: "Samsung 75 Oled")
            detailDivider
            detailRow(label: "Note", value: "Fragile")
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(red: 0.90, green: 0.90, blue: 0.91), lineWidth: 1)
        )
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
        }
        .padding(.vertical, 4)
    }
    
    private var detailDivider: some View {
        Divider()
            .padding(.vertical, 6)
    }
    
    // MARK: - Contact Rider
    private var contactRiderSection: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color(red: 0.92, green: 0.92, blue: 0.93))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Mr John")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                Text("Contact Rider")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
        )
    }
    
    // MARK: - Timeline
    private var timelineSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(timelineEntries.enumerated()), id: \.element.id) { index, entry in
                HStack(alignment: .top, spacing: 0) {
                    // Time + Date
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(entry.time)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        Text(entry.date)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 70, alignment: .trailing)
                    
                    // Timeline dot + line
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(entry.isCompleted ? Color.black : Color(red: 0.88, green: 0.88, blue: 0.89))
                                .frame(width: 24, height: 24)
                            
                            if entry.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if index < timelineEntries.count - 1 {
                            Rectangle()
                                .fill(Color(red: 0.88, green: 0.88, blue: 0.89))
                                .frame(width: 2)
                                .frame(height: 50)
                        }
                    }
                    .frame(width: 36)
                    
                    // Description
                    Text(entry.description)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineSpacing(3)
                        .padding(.top, 2)
                    
                    Spacer()
                }
                .padding(.bottom, index < timelineEntries.count - 1 ? 0 : 0)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        OrderTrackingView()
    }
}
