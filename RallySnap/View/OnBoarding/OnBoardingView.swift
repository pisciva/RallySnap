//
//  OnBoardingView.swift
//  RallySnap
//
//  Created by Belmiro Kayru on 05/05/26.
//
import SwiftUI
import CoreLocation

struct OnBoardingView: View{
    @State private var currentPage = 0
    @StateObject private var locationManager = LocationManager()
    let accent = Color(red: 217/255, green: 255/255, blue: 78/255)
    let welcomeItem = OnBoardingItem(
        title: "Welcome to RallySnap",
        description: "Capture your best tennis moments automatically."
    )
    let locationItem = OnBoardingItem(
        title: "Enable Location",
        description: "Allow location to help organize your sessions by place."
    )
    let onFinish: () -> Void
    
    private var locationButtonTitle: String {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return "Continue"
        case .denied, .restricted:
            return "Continue Without Location"
        case .notDetermined:
            return "Enable Location"
        @unknown default:
            return "Continue"
        }
    }
    
    var body: some View{
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 12) {
                HStack(spacing: 8){
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? accent : Color(white: 0.25))
                            .frame(width: currentPage == index ? 64 : 48, height: 6)
                            .animation(.easeInOut(duration: 0.25), value: currentPage)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 6)
                
                TabView(selection: $currentPage){
                    OnBoardingPageView(item: welcomeItem)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(0)
                    
                    VStack(spacing: 24){
                        Spacer(minLength: 0)
                        
                        Text("How RallySnap Works").foregroundColor(accent).font(.system(size: 28, weight: .bold))
                        
                        VStack(alignment: .leading,spacing: 20) {
                            HStack(spacing: 12){
                                Image(systemName: "iphone")
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(accent)
                                    .clipShape(Circle())
                                
                                Text("Set up your phone").foregroundColor(accent)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "record.circle")
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(accent)
                                    .clipShape(Circle())
                                
                                Text("Record your game").foregroundColor(accent)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(accent)
                                    .clipShape(Circle())
                                
                                Text("Let AI clip the best moves").foregroundColor(accent)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "video")
                                    .foregroundColor(.black)
                                    .frame(width: 36, height: 36)
                                    .background(accent)
                                    .clipShape(Circle())
                                
                                Text("Your clips are ready").foregroundColor(accent)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(1)
                    
                    VStack(spacing: 16) {
                        Spacer(minLength: 0)
                        
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(accent)
                        
                        Text(locationItem.title)
                            .foregroundColor(accent)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text(locationItem.description)
                            .foregroundColor(.gray)
                            .font(.system(size: 18, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button(action: {
                            switch locationManager.authorizationStatus {
                            case .notDetermined:
                                locationManager.requestPermission()
                            default:
                                onFinish()
                            }
                        }) {
                            Text(locationButtonTitle)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(accent)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                            Text("Location access is off. You can still continue and enable it later in Settings.")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .regular))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
