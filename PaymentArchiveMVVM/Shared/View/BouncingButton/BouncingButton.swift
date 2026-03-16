//
//  BouncingButton.swift
//  PaymentArchiveMVVM
//
//  Created by Codex on 27.02.2026.
//

import SwiftUI

struct BouncingButton<Content: View>: View {
  let action: () -> Void
  @ViewBuilder let label: () -> Content

  @State private var isBouncing = false
  @State private var isPressed = false

  var body: some View {
    Button(
      action: {
        withAnimation(.interpolatingSpring(stiffness: 50, damping: 5)) {
          isBouncing.toggle()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isBouncing.toggle()
            action()
          }
        }
      }
    ) {
      label()
    }
    .scaleEffect(isPressed ? 0.95 : (isBouncing ? 1.1 : 1.0))
    .animation(.easeInOut(duration: 0.2), value: isPressed)
    .animation(.easeInOut, value: isBouncing)
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in isPressed = true }
        .onEnded { _ in isPressed = false }
    )
    .disabled(isBouncing)
  }
}
