import SwiftUI
internal import Combine

// MARK: - Support Action Model
struct SupportAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let displayTitle: String // single-line version for chat bubble
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// MARK: - Support System View
struct SupportSystemView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var askText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var showGrid: Bool = true
    @State private var showTypingIndicator: Bool = false

    private let allActions: [SupportAction] = [
        SupportAction(icon: "doc.text.fill", title: "Track My\nOrder", displayTitle: "Track My Order"),
        SupportAction(icon: "arrow.left.arrow.right", title: "Return /\nExchange Item", displayTitle: "Return / Exchange Item"),
        SupportAction(icon: "checkmark.circle.fill", title: "Product\nAvailability", displayTitle: "Product Availability"),
        SupportAction(icon: "creditcard.fill", title: "Payment\nIssue", displayTitle: "Payment Issue"),
        SupportAction(icon: "shippingbox.fill", title: "Delivery\nDetails", displayTitle: "Delivery Details"),
        SupportAction(icon: "headphones.circle.fill", title: "Contact\nSupport", displayTitle: "Contact Support"),
    ]

    // Split into rows of 3
    private var actionRows: [[SupportAction]] {
        stride(from: 0, to: allActions.count, by: 3).map {
            Array(allActions[$0..<min($0 + 3, allActions.count)])
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return "Good Morning !" }
        else if hour < 17 { return "Good Afternoon !" }
        else { return "Good Evening !" }
    }

    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: .now)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            headerRow
            
            // MARK: - Content
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Greeting
                        greetingSection
                        
                        // Chat messages
                        if !messages.isEmpty {
                            chatSection
                                .padding(.top, 10)
                        }
                        
                        // Typing indicator
                        if showTypingIndicator {
                            typingBubble
                                .padding(.top, 12)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .id("typing")
                        }
                        
                        // Spacer to push grid down or fill space
                        if showGrid {
                            Spacer(minLength: 40)
                                .frame(maxHeight: .infinity)
                        }
                        
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .frame(minHeight: showGrid ? 0 : nil)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: showTypingIndicator) { _, showing in
                    if showing {
                        withAnimation {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            // MARK: - Bottom: Grid or Ask Bar
            VStack(spacing: 12) {
                if showGrid {
                    actionGrid
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity.combined(with: .scale(scale: 0.9)).combined(with: .move(edge: .bottom))
                            )
                        )
                        .padding(.horizontal, 20)
                }

                askBar
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 12)
        }
        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Header Row
    private var headerRow: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                    )
            }

            Spacer()

            Text("Help & Support")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }

    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)

            Text("here are your tasks\nfor today.")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(white: 0.6))
                .lineSpacing(3)

            Text(currentTime)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0.88, green: 0.88, blue: 0.88))
                )
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    // MARK: - Chat Section
    private var chatSection: some View {
        VStack(spacing: 12) {
            ForEach(messages) { message in
                chatBubble(message: message)
                    .transition(
                        .asymmetric(
                            insertion: .opacity
                                .combined(with: .scale(scale: 0.8, anchor: message.isUser ? .bottomTrailing : .bottomLeading))
                                .combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        )
                    )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Chat Bubble
    private func chatBubble(message: ChatMessage) -> some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            if !message.isUser {
                // Bot avatar
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if !message.isUser {
                    Text("Support")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(white: 0.5))
                }

                Text(message.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(message.isUser ? .white : .black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                message.isUser
                                    ? Color(red: 0.10, green: 0.10, blue: 0.16)
                                    : .white
                            )
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    )
            }

            if !message.isUser { Spacer(minLength: 60) }
        }
    }

    // MARK: - Typing Indicator Bubble
    private var typingBubble: some View {
        HStack {
            Image(systemName: "headphones.circle.fill")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.58))

            VStack(alignment: .leading, spacing: 4) {
                Text("Support")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(white: 0.5))

                TypingDotsView()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    )
            }

            Spacer(minLength: 60)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Action Grid
    private var actionGrid: some View {
        VStack(spacing: 10) {
            ForEach(0..<actionRows.count, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(actionRows[row]) { action in
                        actionCard(action: action)
                    }
                }
            }
        }
    }

    private func actionCard(action: SupportAction) -> some View {
        Button {
            handleActionTap(action)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: action.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)

                Spacer()

                Text(action.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .frame(height: 110)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.86, green: 0.86, blue: 0.87))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Ask Bar
    private var askBar: some View {
        HStack(spacing: 12) {
            TextField("Ask Anything .......", text: $askText)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.black)
                .tint(.black)
                .onSubmit {
                    sendTextMessage()
                }

            Button {
                // Microphone action
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.86, green: 0.86, blue: 0.87))
        )
    }

    // MARK: - Actions
    private func handleActionTap(_ action: SupportAction) {
        // Step 1: Hide grid with animation
        withAnimation(.easeInOut(duration: 0.35)) {
            showGrid = false
        }

        // Step 2: After grid fades, add user message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let userMsg = ChatMessage(text: action.displayTitle, isUser: true)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                messages.append(userMsg)
            }

            // Step 3: Show typing indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTypingIndicator = true
                }

                // Step 4: Replace typing with bot reply
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTypingIndicator = false
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        let reply = ChatMessage(
                            text: "Thanks for reaching out! We've noted your request regarding \"\(action.displayTitle)\". Our team will contact you shortly. 🙌",
                            isUser: false
                        )
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            messages.append(reply)
                        }

                        // Step 5: Bring back the grid after reply
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showGrid = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func sendTextMessage() {
        let trimmed = askText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Hide grid
        withAnimation(.easeInOut(duration: 0.3)) {
            showGrid = false
        }
        askText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let userMsg = ChatMessage(text: trimmed, isUser: true)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                messages.append(userMsg)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTypingIndicator = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTypingIndicator = false
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        let reply = ChatMessage(
                            text: "We've received your message. Our support team will contact you later. Thank you for your patience! 🙏",
                            isUser: false
                        )
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            messages.append(reply)
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showGrid = true
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Typing Dots Animation
struct TypingDotsView: View {
    @State private var activeDot = 0
    
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(white: activeDot == index ? 0.3 : 0.7))
                    .frame(width: 8, height: 8)
                    .scaleEffect(activeDot == index ? 1.25 : 1.0)
                    .animation(.easeInOut(duration: 0.35), value: activeDot)
            }
        }
        .onReceive(timer) { _ in
            activeDot = (activeDot + 1) % 3
        }
    }
}

// MARK: - Scale Button Style (press feedback)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SupportSystemView()
    }
}
