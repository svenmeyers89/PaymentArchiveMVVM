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

  @State private var isBouncing = false
  @State private var isPressed = false
  
  var body: some View {
    Button(
      action: {
        withAnimation(.interpolatingSpring(stiffness: 50, damping: 5)) {
          isBouncing.toggle()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isBouncing.toggle()
            action() // Trigger the provided action
          }
        }
      }) {
        ZStack {
          buttonBackground
            .frame(width: size, height: size)
            .shadow(radius: 10)
          Image(systemName: iconName)
            .foregroundColor(colors.icon)
            .font(.system(size: size / 2, weight: .bold))
        }
      }
      .scaleEffect(isPressed ? 0.9 : (isBouncing ? 1.2 : 1.0)) // Bounce effect
      .animation(.easeInOut(duration: 0.2), value: isPressed) // Smooth shrink and release
      .animation(.easeInOut, value: isBouncing)
      .simultaneousGesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            isPressed = true // Shrink on press
          }
          .onEnded { _ in
            isPressed = false // Reset after press
          }
      )
      .disabled(isBouncing)
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

extension CircleButton {
  struct Colors {
    let background: Color
    let icon: Color
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
