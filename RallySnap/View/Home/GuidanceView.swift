import SwiftUI

struct GuidanceView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                
                TabView(selection: $currentPage) {
                    
                    VStack(spacing: 20) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.85, green: 1.0, blue: 0.31))
                        
                        Text("Optimal Placement")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Place your device 2-3 meters behind the baseline. Ensure the entire court and net are visible.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(0)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "figure.tennis")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.85, green: 1.0, blue: 0.31))
                        
                        Text("AI Auto-Clipping")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Just play your game. Our AI automatically analyzes your movement and clips your best strokes.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(1)
                    VStack(spacing: 20) {
                        Image(systemName: "applewatch")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.85, green: 1.0, blue: 0.31))
                        
                        Text("Manual Control")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Tap your Apple Watch after a great shot to manually save the last 30 seconds.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(2)
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.85, green: 1.0, blue: 0.31))
                        
                        Text("Ready to Play")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Your setup is complete. Step onto the court and let's capture your highlights!")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(3) // Identitas halaman 4
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                
                
                ZStack {
                    
                    HStack(spacing: 8) {
                        Circle().fill(currentPage == 0 ? Color(red: 0.85, green: 1.0, blue: 0.31) : Color.gray).frame(width: 8, height: 8)
                        Circle().fill(currentPage == 1 ? Color(red: 0.85, green: 1.0, blue: 0.31) : Color.gray).frame(width: 8, height: 8)
                        Circle().fill(currentPage == 2 ? Color(red: 0.85, green: 1.0, blue: 0.31) : Color.gray).frame(width: 8, height: 8)
                        Circle().fill(currentPage == 3 ? Color(red: 0.85, green: 1.0, blue: 0.31) : Color.gray).frame(width: 8, height: 8)
                    }
                    
                    HStack {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation { currentPage -= 1 }
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        if currentPage < 3 {
                            Button(action: {
                                withAnimation { currentPage += 1 }
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 0.85, green: 1.0, blue: 0.31))
                            }
                        } else {
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Start Clipping")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0.85, green: 1.0, blue: 0.31))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    GuidanceView()
}
