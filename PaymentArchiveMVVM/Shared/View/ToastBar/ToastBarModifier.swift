//
//  ToastBarModifier.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 04.03.2026..
//

import SwiftUI

extension View {
  func toastBar(
    toastBarMessage: Binding<ToastBar.Message?>,
    duration: Int = 1,
    colors: ToastBar.Colors
  ) -> some View {
    modifier(
      ToastBarModifier(
        toastBarMessage: toastBarMessage,
        duration: duration,
        colors: colors
      )
    )
  }
}

@MainActor
private final class AnimationTaskWrapper {
  var animationTask: Task<Void, Never>?
}

private struct ToastBarModifier: ViewModifier {
  @Binding var toastBarMessage: ToastBar.Message?
  let duration: Int
  let colors: ToastBar.Colors

  private let hideTaskWrapper: AnimationTaskWrapper = .init()
  
  @State private var isVisible: Bool = false

  func body(content: Content) -> some View {
    ZStack(alignment: .bottom) {
      content

      if let toastBarMessage {
        ToastBar(
          message: toastBarMessage,
          colors: colors
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 12)
        .opacity(isVisible ? 1 : 0)
        .transition(.opacity)
        .onAppear {
          withAnimation(.easeIn(duration: 0.3)) {
            isVisible = true
          } completion: {
            hideTaskWrapper.animationTask = Task {
              try? await Task.sleep(nanoseconds: 1_000_000_000)
              
              withAnimation(.easeIn(duration: 0.3)) {
                isVisible = true
              } completion: {
                self.toastBarMessage = nil
              }
            }
          }
        }
        .onDisappear {
          hideTaskWrapper.animationTask?.cancel()
          hideTaskWrapper.animationTask = nil
        }
      }
    }
  }
}
