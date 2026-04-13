//
//  CircleButton.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 23.08.2025..
//

import SwiftUI

struct CircleButton: View {
  let size: CGFloat
  let iconName: String
  let colors: Colors
  let action: () -> Void

  var body: some View {
    BouncingButton(action: action) {
      ZStack {
        buttonBackground
          .frame(width: size, height: size)
          .shadow(radius: 10)
        Image(systemName: iconName)
          .foregroundColor(colors.icon)
          .font(.system(size: size / 2, weight: .bold))
      }
    }
  }
}

extension CircleButton {
  @ViewBuilder
  private var buttonBackground: some View {
    let baseCircle = Circle().fill(colors.background)
    
    if #available(iOS 26.0, *) {
      baseCircle.glassEffect()
    } else {
      baseCircle
    }
  }
}

#Preview {
  CircleButton(
    size: 96,
    iconName: "plus",
    colors: .init(background: .blue, icon: .white)
  ) {
    print("button is tapped!")
  }
}
