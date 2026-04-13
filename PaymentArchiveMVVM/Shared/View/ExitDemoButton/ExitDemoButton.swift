//
//  ExitDemoButton.swift
//  PaymentArchiveMVVM
//

import SwiftUI

struct ExitDemoButton: View {
  let title: String
  let colors: Colors
  let action: () -> Void

  var body: some View {
    BouncingButton(action: action) {
      Text(title)
        .font(.headline)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .foregroundStyle(colors.text)
        .background(
          RoundedRectangle(cornerRadius: 14)
            .fill(colors.background)
            .shadow(radius: 8, y: 4)
        )
    }
  }
}
