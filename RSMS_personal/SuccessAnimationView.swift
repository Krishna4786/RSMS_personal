import SwiftUI

// MARK: - Success Animation View (Bottom Sheet)
struct SuccessAnimationView: View {
    var title: String = "Successful"
    var message: String = "Your order has been placed successfully!"
    
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var checkmarkOpacity: Double = 0.0
    @State private var circleScale: CGFloat = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            
            // Animated success icon
            ZStack {
                // Pulse rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color(red: 0.82, green: 0.95, blue: 0.35).opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale + (CGFloat(index) * 0.15))
                        .opacity(pulseOpacity - (Double(index) * 0.2))
                }
                
                // Main circle background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.85, green: 0.98, blue: 0.40),
                                Color(red: 0.78, green: 0.92, blue: 0.30)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(circleScale)
                
                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)
            }
            .frame(height: 150)
            
            Spacer().frame(height: 30)
            
            // Success text
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(textOpacity)
            
            Spacer().frame(height: 50)
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(30)
        .presentationBackground(.white)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Circle scale animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
            circleScale = 1.0
        }
        
        // Checkmark animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.4)) {
            checkmarkScale = 1.0
            checkmarkOpacity = 1.0
        }
        
        // Pulse animation
        withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
            pulseOpacity = 0.6
        }
        
        withAnimation(.easeOut(duration: 1.5).delay(0.4).repeatForever(autoreverses: false)) {
            pulseScale = 1.4
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.4).delay(0.6)) {
            textOpacity = 1.0
        }
    }
}

// MARK: - Preview
#Preview {
    Text("Main Content")
        .sheet(isPresented: .constant(true)) {
            SuccessAnimationView(
                title: "Order Placed!",
                message: "Your order has been placed successfully!"
            )
        }
}
