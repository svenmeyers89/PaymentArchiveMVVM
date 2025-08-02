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
  
  @State private var isVisible: Bool = false
  
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
  
  func animateInAndOut(
    duration: Int,
    completion: @escaping () -> Void
  ) -> some View {
    self
      .opacity(isVisible ? 1 : 0)
      .transition(.opacity)
      .onAppear {
        withAnimation(.easeIn(duration: 0.3)) {
          isVisible = true
        }

        // Delay before hiding
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
          withAnimation(.easeOut(duration: 0.3)) {
            isVisible = false
          }

          // Remove toast after fade out
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion()
          }
        }
    }
  }
}

struct ToastContainer<Content: View>: View {
  @Binding var toastBarMessage: ToastBar.Message?
  
  let content: () -> Content
  let completion: () -> Void

  let duration: Int
  let colors: ToastBar.Colors

  @State private var isVisible: Bool = false
  
  init(
    toastBarMessage: Binding<ToastBar.Message?>,
    duration: Int = 1,
    colors: ToastBar.Colors = .default,
    @ViewBuilder content: @escaping () -> Content,
    completion: @escaping () -> Void
  ) {
    self._toastBarMessage = toastBarMessage
    self.completion = completion
    self.duration = duration
    self.colors = colors
    self.content = content
  }

  var body: some View {
    ZStack {
      content()

      if let toastBarMessage {
        ToastBar(
          message: toastBarMessage,
          colors: ToastBar.Colors.default
        )
        .opacity(isVisible ? 1 : 0)
        .transition(.opacity)
        .onAppear {
          withAnimation(.easeIn(duration: 0.3)) {
            isVisible = true
          }
          
          // Delay before hiding
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
            withAnimation(.easeOut(duration: 0.3)) {
              isVisible = false
            }
            
            // Remove toast after fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
              completion()
            }
          }
        }
      }
    }
  }
}

struct ToastBarPresenter: View {
  let toastMessage: ToastBar.Message
  let duration: Int
  let completion: () -> Void
  
  @State private var isVisible: Bool = false
  
  var body: some View {
    ToastBar(
      message: toastMessage,
      colors: ToastBar.Colors.default
    )
    .opacity(isVisible ? 1 : 0)
    .transition(.opacity)
    .onAppear {
      withAnimation(.easeIn(duration: 0.3)) {
        isVisible = true
      }
      
      // Delay before hiding
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
        withAnimation(.easeOut(duration: 0.3)) {
          isVisible = false
        }
        
        // Remove toast after fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          completion()
        }
      }
    }
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
