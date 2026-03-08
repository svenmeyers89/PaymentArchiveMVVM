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
  }
}

#Preview {
  ToastBar(
    message: .init(
      text: "Something went wrong",
      type: .error
    ),
    colors: ToastBar.Colors(
      background: Color(white: 0.2, opacity: 0.75),
      icon: .white,
      text: .white
    )
  )
}
