//
//  OnBoardingPageView.swift
//  RallySnap
//
//  Created by Belmiro Kayru on 05/05/26.
//

import SwiftUI

struct OnBoardingPageView: View {
      let item: OnBoarding
      let accent = Color(red: 217/255, green: 255/255, blue: 78/255)

      var body: some View {
          VStack(spacing: 16) {
              Text(item.title)
                  .foregroundColor(accent)
                  .font(.system(size: 28, weight: .bold))
                  .multilineTextAlignment(.center)

              Text(item.description)
                  .foregroundColor(.gray)
                  .font(.system(size: 18, weight: .regular))
                  .multilineTextAlignment(.center)
                  .padding(.horizontal, 24)
          }
      }
  }

