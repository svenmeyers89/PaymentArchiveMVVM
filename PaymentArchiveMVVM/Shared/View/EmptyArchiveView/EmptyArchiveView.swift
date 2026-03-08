//
//  EmptyView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 09.08.2025..
//

import SwiftUI

struct EmptyArchiveView: View {
  let colors: Colors
  let configuration: Configuration

  var body: some View {
    GeometryReader { geometry in
      ScrollView(.vertical) {
        VStack(alignment: .center) {
          if let iconName = configuration.iconName {
            let maxSide: CGFloat = 120
            Image(systemName: iconName)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: maxSide, maxHeight: maxSide)
              .padding(.bottom, 24)
              .foregroundStyle(colors.icon)
          }
          if let title = configuration.title {
            Text(title)
              .font(.title)
              .multilineTextAlignment(.center)
              .padding(.bottom, 12)
              .foregroundStyle(colors.title)
          }
          if let description = configuration.description {
            Text(description)
              .font(.body)
              .lineSpacing(8)
              .multilineTextAlignment(.center)
              .padding(.bottom, 36)
              .foregroundStyle(colors.description)
          }

          ForEach(configuration.buttons) { button in
            Button(button.title) {
              button.action()
            }
            .padding(.bottom, 12)
            .foregroundStyle(colors.button)
          }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: geometry.size.height)
        .padding()
      }
    }
  }
}

#Preview {
  EmptyArchiveView(
    colors: .init(
      icon: .blue,
      title: .primary,
      description: .primary,
      button: .blue
    ),
    configuration:
      EmptyArchiveView.Configuration.onboarding(
        createAccountAction: { print("Create Action") },
        showDemoAction: { print("Show Demo") }
      )
//    EmptyView.Configuration.emptyArchive(
//      addPaymentAction: { print("Add Payment") }
//    )
  )
}
