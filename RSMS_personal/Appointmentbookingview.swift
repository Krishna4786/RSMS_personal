import SwiftUI

// MARK: - Store Model
struct AppointmentsStoreLocation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String
    let distance: String
}

// MARK: - Time Slot
struct TimeSlot: Identifiable {
    let id = UUID()
    let time: String
    let hour: Int
    let minute: Int
    var status: SlotStatus
}

enum SlotStatus {
    case available, booked, selected
}

// MARK: - Appointment Purpose
struct AppointmentPurpose: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
}

// MARK: - Booked Appointment
struct BookedAppointment: Identifiable {
    let id = UUID()
    let store: String
    let date: String
    let time: String
    let purpose: String
    let status: AppointmentStatus
}

enum AppointmentStatus: String {
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var color: Color {
        switch self {
        case .confirmed: return Color(red: 0.22, green: 0.78, blue: 0.42)
        case .completed: return Color(red: 0.40, green: 0.55, blue: 0.85)
        case .cancelled: return Color(red: 0.85, green: 0.30, blue: 0.30)
        }
    }
}

// MARK: - Day Item
struct DayItem: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let dayName: String
    let dayNumber: String
    let isToday: Bool
}

// MARK: - Grid Selection
struct GridSelection: Equatable {
    let dayIndex: Int
    let timeIndex: Int
}

// MARK: - Appointment Booking View
struct AppointmentBookingView: View {

    @Environment(\.dismiss) private var dismiss

    // State
    @State private var selectedStore: AppointmentsStoreLocation?
    @State private var showStorePicker = false
    @State private var selectedGridCell: GridSelection? = nil
    @State private var selectedPurpose: AppointmentPurpose?
    @State private var activeTab: BookingTab = .upcoming
    @State private var bookingConfirmed = false
    @State private var appeared = false
    @State private var gridRevealed = false
    @State private var note: String = ""

    // Grid state: [timeIndex][dayIndex] = CellState
    @State private var gridStates: [[SlotStatus]] = []

    // Data
    private let stores: [AppointmentsStoreLocation] = [
        AppointmentsStoreLocation(name: "Store.M — Connaught Place", address: "Block A, CP, New Delhi", distance: "2.3 km"),
        AppointmentsStoreLocation(name: "Store.M — Khan Market", address: "Middle Lane, Khan Market", distance: "4.1 km"),
        AppointmentsStoreLocation(name: "Store.M — Select Citywalk", address: "Saket, New Delhi", distance: "7.8 km"),
    ]

    private let purposes: [AppointmentPurpose] = [
        AppointmentPurpose(icon: "tshirt.fill", title: "Personal Styling"),
        AppointmentPurpose(icon: "bag.fill", title: "Shopping Assist"),
        AppointmentPurpose(icon: "ruler.fill", title: "Alterations"),
        AppointmentPurpose(icon: "gift.fill", title: "Gift Consultation"),
    ]

    private let pastAppointments: [BookedAppointment] = [
        BookedAppointment(store: "Store.M — Connaught Place", date: "12 Mar 2026", time: "11:00 AM", purpose: "Personal Styling", status: .completed),
        BookedAppointment(store: "Store.M — Khan Market", date: "05 Mar 2026", time: "3:00 PM", purpose: "Shopping Assist", status: .completed),
        BookedAppointment(store: "Store.M — Select Citywalk", date: "28 Feb 2026", time: "10:00 AM", purpose: "Alterations", status: .cancelled),
    ]

    private let upcomingAppointments: [BookedAppointment] = [
        BookedAppointment(store: "Store.M — Khan Market", date: "22 Mar 2026", time: "2:00 PM", purpose: "Personal Styling", status: .confirmed),
    ]

    // Time labels (rows)
    private let timeLabels = ["9:00", "10:00", "11:00", "12:00", "1:00", "2:00", "3:00", "4:00", "5:00"]

    // Visible days (columns) — next 5 weekdays
    private var visibleDays: [DayItem] {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        let dayNumFormatter = DateFormatter()
        formatter.dateFormat = "EEE"
        dayNumFormatter.dateFormat = "d"

        var result: [DayItem] = []
        var offset = 0
        while result.count < 5 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { offset += 1; continue }
            let weekday = calendar.component(.weekday, from: date)
            // Skip Sunday (1) and Saturday (7)
            if weekday != 1 && weekday != 7 {
                result.append(DayItem(
                    date: date,
                    dayName: formatter.string(from: date),
                    dayNumber: dayNumFormatter.string(from: date),
                    isToday: offset == 0
                ))
            }
            offset += 1
        }
        return result
    }

    // Colors
    private let accent = Color(red: 0.95, green: 0.75, blue: 0.25)
    private let textPrimary = Color(red: 0.10, green: 0.10, blue: 0.12)
    private let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)
    private let cellAvailable = Color(red: 0.91, green: 0.91, blue: 0.92)
    private let cellBooked = Color(red: 0.15, green: 0.15, blue: 0.18)

    enum BookingTab: String, CaseIterable {
        case upcoming = "Upcoming"
        case past = "Past"
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Store Selector
                storeSelector
                    .padding(.top, 8)

                // MARK: - Grid (Days × Time)
                slotGrid
                    .padding(.top, 24)

                // MARK: - Purpose (appears after slot selected)
                if selectedGridCell != nil {
                    purposeSelector
                        .padding(.top, 24)
                }

                // MARK: - Notes
                if selectedPurpose != nil {
                    notesSection
                        .padding(.top, 20)
                }

                // MARK: - Booking Summary + Confirm
                if selectedGridCell != nil && selectedPurpose != nil {
                    bookingSummary
                        .padding(.top, 24)
                }

                // MARK: - Appointments Tabs
                appointmentsList
                    .padding(.top, 32)
                    .padding(.bottom, 40)
            }
        }
        .background(Color(red: 0.965, green: 0.965, blue: 0.965))
        .navigationTitle("Appointment Booking")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedStore == nil { selectedStore = stores.first }
            generateGrid()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation { appeared = true }
                withAnimation { gridRevealed = true }
            }
        }
        .sheet(isPresented: $showStorePicker) {
            storePickerSheet
        }
        .overlay {
            if bookingConfirmed {
                confirmationOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    }

    // MARK: - Generate Grid
    private func generateGrid() {
        // Randomly mark some cells as booked
        let bookedPositions: Set<String> = [
            "1-2", "2-0", "3-3", "4-1", "5-4", "6-2", "7-1", "0-3", "8-0"
        ]
        gridStates = (0..<timeLabels.count).map { timeIdx in
            (0..<5).map { dayIdx in
                bookedPositions.contains("\(timeIdx)-\(dayIdx)") ? .booked : .available
            }
        }
    }

    // MARK: - Store Selector
    private var storeSelector: some View {
        Button {
            showStorePicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(accent)

                VStack(alignment: .leading, spacing: 1) {
                    Text(selectedStore?.name ?? "Select Store")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(textPrimary)
                    if let store = selectedStore {
                        Text(store.address)
                            .font(.system(size: 12))
                            .foregroundColor(textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textSecondary)
            }
            .padding(16)
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
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: appeared)
    }

    // MARK: - Store Picker Sheet
    private var storePickerSheet: some View {
        NavigationStack {
            List(stores) { store in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedStore = store
                    }
                    showStorePicker = false
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(accent)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(store.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(textPrimary)
                            Text(store.address)
                                .font(.system(size: 13))
                                .foregroundColor(textSecondary)
                        }

                        Spacer()

                        Text(store.distance)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color(white: 0.95)))

                        if selectedStore?.id == store.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(accent)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(selectedStore?.id == store.id ? accent.opacity(0.06) : Color.clear)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showStorePicker = false }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Slot Grid (Matrix Layout)
    private var slotGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section title + legend
            HStack {
                Text("Days")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textPrimary)

                Spacer()

                HStack(spacing: 10) {
                    legendDot(color: cellAvailable, label: "Available")
                    legendDot(color: cellBooked, label: "Booked")
                    legendDot(color: accent, label: "Selected")
                }
            }
            .padding(.horizontal, 20)

            // Column headers (day labels)
            HStack(spacing: 6) {
                // Empty space for time label column
                Color.clear.frame(width: 44, height: 1)

                ForEach(Array(visibleDays.enumerated()), id: \.element.id) { index, day in
                    VStack(spacing: 2) {
                        Text(day.dayName)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(day.isToday ? textPrimary : Color(white: 0.88))
                    )
                    .foregroundColor(day.isToday ? .white : textPrimary)
                }
            }
            .padding(.horizontal, 16)

            // Grid rows
            ForEach(Array(timeLabels.enumerated()), id: \.offset) { timeIdx, timeLabel in
                HStack(spacing: 6) {
                    // Time label
                    Text(timeLabel)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(textSecondary)
                        .frame(width: 44, alignment: .leading)

                    // Day cells
                    ForEach(0..<5, id: \.self) { dayIdx in
                        gridCell(timeIndex: timeIdx, dayIndex: dayIdx)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private func gridCell(timeIndex: Int, dayIndex: Int) -> some View {
        let isBooked = gridStates.isEmpty ? false : gridStates[timeIndex][dayIndex] == .booked
        let isSelected = selectedGridCell == GridSelection(dayIndex: dayIndex, timeIndex: timeIndex)
        let flatIndex = timeIndex * 5 + dayIndex

        return Button {
            guard !isBooked else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isSelected {
                    selectedGridCell = nil
                    selectedPurpose = nil
                } else {
                    selectedGridCell = GridSelection(dayIndex: dayIndex, timeIndex: timeIndex)
                    selectedPurpose = nil
                }
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    isBooked ? cellBooked :
                    isSelected ? accent.opacity(0.08) :
                    cellAvailable
                )
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            isSelected ? accent : Color.clear,
                            lineWidth: isSelected ? 2.5 : 0
                        )
                )
                .shadow(color: isSelected ? accent.opacity(0.25) : .clear, radius: 6, y: 2)
                .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isBooked)
        .opacity(gridRevealed ? 1 : 0)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.8)
                .delay(Double(flatIndex) * 0.012),
            value: gridRevealed
        )
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(textSecondary)
        }
    }

    // Selected day/time as readable strings
    private var selectedDayLabel: String {
        guard let cell = selectedGridCell, cell.dayIndex < visibleDays.count else { return "" }
        let day = visibleDays[cell.dayIndex]
        return "\(day.dayName), \(day.dayNumber) Mar 2026"
    }

    private var selectedTimeLabel: String {
        guard let cell = selectedGridCell, cell.timeIndex < timeLabels.count else { return "" }
        let hour = cell.timeIndex + 9
        return "\(timeLabels[cell.timeIndex]) \(hour < 12 ? "AM" : "PM")"
    }

    // MARK: - Purpose Selector
    private var purposeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Purpose of Visit")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textPrimary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(purposes) { purpose in
                        purposeChip(purpose)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func purposeChip(_ purpose: AppointmentPurpose) -> some View {
        let isSelected = selectedPurpose?.id == purpose.id

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedPurpose = isSelected ? nil : purpose
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: purpose.icon)
                    .font(.system(size: 14, weight: .medium))
                Text(purpose.title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isSelected ? textPrimary : .white)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
            .overlay(
                Capsule().stroke(isSelected ? Color.clear : Color(white: 0.92), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notes
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes (optional)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textPrimary)

            TextField("Any special requests or preferences...", text: $note, axis: .vertical)
                .font(.system(size: 14))
                .lineLimit(3...5)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(white: 0.92), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Booking Summary
    private var bookingSummary: some View {
        VStack(spacing: 16) {
            VStack(spacing: 14) {
                summaryRow(icon: "mappin.circle.fill", label: "Store", value: selectedStore?.name ?? "")
                Divider()
                summaryRow(icon: "calendar", label: "Date", value: selectedDayLabel)
                Divider()
                summaryRow(icon: "clock.fill", label: "Time", value: selectedTimeLabel)
                Divider()
                summaryRow(icon: "tag.fill", label: "Purpose", value: selectedPurpose?.title ?? "")
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(accent.opacity(0.2), lineWidth: 1)
            )

            Button {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    bookingConfirmed = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Confirm Appointment")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(textPrimary)
                )
            }
        }
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(accent)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(textSecondary)
                .frame(width: 55, alignment: .leading)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textPrimary)
                .lineLimit(1)

            Spacer()
        }
    }

    // MARK: - Confirmation Overlay
    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.78, blue: 0.42).opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56, weight: .medium))
                        .foregroundColor(Color(red: 0.22, green: 0.78, blue: 0.42))
                        .symbolEffect(.bounce, value: bookingConfirmed)
                }

                Text("Booking Confirmed!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(textPrimary)

                Text("Your appointment has been booked.\nYou'll receive a confirmation shortly.")
                    .font(.system(size: 14))
                    .foregroundColor(textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                VStack(spacing: 8) {
                    Text("\(selectedDayLabel) · \(selectedTimeLabel)")
                        .font(.system(size: 15, weight: .semibold))
                    Text(selectedStore?.name ?? "")
                        .font(.system(size: 13))
                        .foregroundColor(textSecondary)
                }
                .padding(.top, 4)

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        bookingConfirmed = false
                        // Mark cell as booked and reset selections
                        if let cell = selectedGridCell {
                            if cell.timeIndex < gridStates.count && cell.dayIndex < gridStates[cell.timeIndex].count {
                                gridStates[cell.timeIndex][cell.dayIndex] = .booked
                            }
                        }
                        selectedGridCell = nil
                        selectedPurpose = nil
                        note = ""
                    }
                } label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(textPrimary)
                        )
                }
                .padding(.top, 8)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
            )
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Appointments List (Upcoming / Past)
    private var appointmentsList: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ForEach(BookingTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: activeTab == tab ? .bold : .medium))
                            .foregroundColor(activeTab == tab ? textPrimary : textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(activeTab == tab ? .white : .clear)
                                    .shadow(color: activeTab == tab ? .black.opacity(0.04) : .clear, radius: 4, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(white: 0.93))
            )
            .padding(.horizontal, 20)

            let appointments = activeTab == .upcoming ? upcomingAppointments : pastAppointments

            if appointments.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundColor(textSecondary.opacity(0.5))
                    Text("No \(activeTab.rawValue.lowercased()) appointments")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 10) {
                    ForEach(appointments) { appt in
                        appointmentCard(appt)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func appointmentCard(_ appt: BookedAppointment) -> some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(String(appt.date.prefix(2)))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(textPrimary)
                Text("Mar")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(textSecondary)
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.1))
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(appt.store)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textPrimary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(appt.time, systemImage: "clock")
                    Label(appt.purpose, systemImage: "tag")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(textSecondary)
            }

            Spacer()

            Text(appt.status.rawValue)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(appt.status.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(appt.status.color.opacity(0.1))
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(white: 0.93), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AppointmentBookingView()
    }
}
