//
//  ToastBar.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 29.07.2025..
//

import SwiftUI

struct ToastBar: View {
  let message: Message
  let colors: Colors
  
  var body: some View {
    HStack(alignment: .center) {
      Image(systemName: message.type.icon)
        .foregroundColor(colors.icon)
      Text(message.text)
        .font(.headline)
        .foregroundStyle(colors.text)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 16)
    .background(colors.background)
    .clipShape(.capsule)
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

extension View {
  func toastBar(
    toastBarMessage: Binding<ToastBar.Message?>,
    duration: Int = 1,
    colors: ToastBar.Colors = .default
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

extension Binding where Value == ToastBar.Message? {
  func showToast(_ message: ToastBar.Message) {
    wrappedValue = message
  }

  func showToast(
    text: String,
    type: ToastBar.Message.MessageType
  ) {
    wrappedValue = .init(text: text, type: type)
  }
}

extension ToastBar {
  struct Message {
    enum MessageType {
      case info
      case error
      
      fileprivate var icon: String {
        switch self {
        case .info:
          return "info.circle"
        case .error:
          return "exclamationmark.triangle"
        }
      }
    }

    let text: String
    let type: MessageType
  }
}

extension ToastBar {
  struct Colors: Sendable {
    let background: Color
    let icon: Color
    let text: Color
    
    static let `default`: Colors = .init(
      background: Color(white: 0.2, opacity: 0.75),
      icon: .white,
      text: .white
    )
  }
}

#Preview {
  ToastBar(
    message: .init(
      text: "Something went wrong",
      type: .error
    ),
    colors: ToastBar.Colors.default
  )
}
