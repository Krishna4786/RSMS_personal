import SwiftUI

/**
 Visual demonstration of the cart animation system
 
 This view shows how the animation works step-by-step
 */

struct CartAnimationPreview: View {
    @State private var showAnimation = false
    @State private var step = 0
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Cart Animation Demo")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Visual representation
                ZStack {
                    // Stage area
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .frame(height: 400)
                        .overlay(
                            GeometryReader { geo in
                                animationStage(in: geo)
                            }
                        )
                }
                .padding()
                
                // Step indicator
                Text(stepDescription)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Controls
                HStack(spacing: 20) {
                    Button("Reset") {
                        withAnimation {
                            step = 0
                            showAnimation = false
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Next Step") {
                        nextStep()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Auto Play") {
                        autoPlay()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
    
    private func animationStage(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Bottom "Add to Cart" button position
            if step >= 0 {
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.blue)
                        .frame(width: 200, height: 50)
                        .overlay(
                            Text("Add to Cart")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        )
                        .padding(.bottom, 40)
                }
            }
            
            // Top cart icon position
            if step >= 0 {
                VStack {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "cart")
                            .font(.title2)
                            .padding()
                            .background(Circle().fill(Color(.systemGray5)))
                            .overlay(alignment: .topTrailing) {
                                if step >= 4 {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Text("1")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                        )
                                        .offset(x: 5, y: -5)
                                        .transition(.scale)
                                }
                            }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            
            // Animated icon
            if step >= 1 && step < 4 {
                animatedIcon(in: geometry)
            }
            
            // Success checkmark
            if step >= 4 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func animatedIcon(in geometry: GeometryProxy) -> some View {
        let startY = geometry.size.height - 80
        let endY: CGFloat = 40
        let startX = geometry.size.width / 2
        let endX = geometry.size.width - 40
        
        let progress: CGFloat = {
            switch step {
            case 1: return 0.0
            case 2: return 0.5
            case 3: return 1.0
            default: return 0.0
            }
        }()
        
        let currentX = startX + (endX - startX) * progress
        let currentY = startY + (endY - startY) * progress
        let scale = 1.0 - (progress * 0.7)
        let opacity = 1.0 - (progress * 0.5)
        
        return Image(systemName: "cart.fill.badge.plus")
            .font(.system(size: 40))
            .foregroundStyle(
                LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .position(x: currentX, y: currentY)
            .transition(.scale.combined(with: .opacity))
    }
    
    private var stepDescription: String {
        switch step {
        case 0:
            return "Ready to add item to cart.\nTap 'Next Step' to begin."
        case 1:
            return "User taps 'Add to Cart' button.\nAnimated icon appears at button position."
        case 2:
            return "Icon springs toward cart in navigation bar.\nScale decreases as it moves."
        case 3:
            return "Icon reaches destination.\nPreparing to update cart badge..."
        case 4:
            return "Success! Item added to cart.\nBadge shows item count."
        default:
            return ""
        }
    }
    
    private func nextStep() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            if step < 4 {
                step += 1
                showAnimation = true
            } else {
                step = 0
                showAnimation = false
            }
        }
    }
    
    private func autoPlay() {
        step = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if step < 4 {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    step += 1
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    CartAnimationPreview()
}
