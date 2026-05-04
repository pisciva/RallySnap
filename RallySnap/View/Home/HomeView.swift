import SwiftUI

struct HomeView: View {
    @State private var showGuidance = false
    
    var body: some View {
        
        ZStack{
            Color.black.ignoresSafeArea()
            ScrollView(showsIndicators: false){
                
                VStack(alignment: .leading){
                    Text("Ready for a match?").foregroundStyle(.white)                               .font(.system(size: 20, weight: .bold))
                    
                    //MARK: Guidance Card
                    Button {
                        showGuidance = true
                    } label: {
                        VStack(spacing:0){
                            Image("asset_homescreen_1")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .frame(height: 160, alignment: .bottom)
                                .clipped()
                            HStack{
                                Text("Click For Guidance")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white)
                            }.padding()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
                    .padding(.bottom, 32)
                
                VStack{
                    
                    HStack{
                        Text("Recently Added").font(.system(size: 20, weight: .regular)).foregroundStyle(.white)
                        Spacer()
                        Text("View All").font(.system(size: 14, weight: .regular)).foregroundStyle(Color(red: 0.85, green: 1.0, blue: 0.31))
                    }.padding(.horizontal, 24)
                }
            }
        }
        
        .fullScreenCover(isPresented: $showGuidance) {
            GuidanceView()
        }
    }
}

#Preview {
    HomeView()
}
