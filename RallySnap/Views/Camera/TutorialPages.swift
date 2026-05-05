import SwiftUI

struct TutorialPageOne: View {
    var isOverlay: Bool
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Image("CourtModel")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260, maxHeight: 180)
                
                Image("CameraLocation")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .foregroundColor(.neonGreen)
            }
            .frame(height: 260)
            
            Spacer().frame(height: 16)
            
            Text("Place your camera here.")
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .shadow(color: .black.opacity(0.8), radius: 2)
                .frame(height: 80, alignment: .top)
            Spacer()
        }
    }
}

struct TutorialPageTwo: View {
    var isOverlay: Bool
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image("TennisCourt3DModel")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 500, maxHeight: 230)
            }
            .frame(height: 260)
            
            Spacer().frame(height: 15)
            
            Text("For best results, your angle should cover all edges of the court.")
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .shadow(color: .black.opacity(0.8), radius: 2)
                .frame(height: 80, alignment: .top)
            Spacer()
        }
    }
}

struct TutorialPageThree: View {
    var isOverlay: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 100) {
                Image(systemName: "figure.tennis")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .foregroundColor(.neonGreen)
                Image(systemName: "hand.raised.brakesignal")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .foregroundColor(.neonGreen)
            }
            .frame(height: 260)
            
            Spacer().frame(height: 20)
            
            Text("We detect actions to clip. Make sure to show your gestures clearly to the camera.")
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .shadow(color: .black.opacity(0.8), radius: 2)
                .frame(height: 80, alignment: .top)
            Spacer()
        }
    }
}

struct TutorialPageFour: View {
    @Binding var showTutorialNextTime: Bool
    var isOverlay: Bool
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ready to go?")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 2)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 16) {
                    Image(systemName: "lightbulb.max.fill")
                        .foregroundColor(.yellow)
                        .frame(width: 30)
                    Text("Ensure you have proper lighting")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2)
                }
                HStack(spacing: 16) {
                    Image(systemName: "battery.25percent")
                        .foregroundColor(.orange)
                        .frame(width: 30)
                    Text("Enabling Low Power Mode is advised")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2)
                }
            }
            .padding(.vertical, 20)
            
            HStack {
                Spacer()
                Text("Show this tutorial next time")
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2)
                
                Spacer()
                        .frame(width: 4)
                
                Toggle("", isOn: $showTutorialNextTime)
                    .labelsHidden()
                    .toggleStyle(ReusableToggleStyle(tint: .green, scale: 0.7))
                Spacer()
            }
            .padding(.bottom, 8)
            
            Button(action: {
                onDismiss()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Session")
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 250)
                .padding(.vertical, 16)
                .background(Color.neonGreen)
                .cornerRadius(25)
            }
        }
    }
}
