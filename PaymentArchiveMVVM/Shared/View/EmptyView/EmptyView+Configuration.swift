//
//  EmptyView+Configuration.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 10.08.2025..
//

extension EmptyView {
  struct ButtonConfiguration: Sendable, Identifiable {
    let title: String
    let action: @Sendable () -> Void

    var id: String { title }
  }
  
  struct Configuration: Sendable {
    let title: String?
    let description: String?
    let iconName: String?
    let buttons: [ButtonConfiguration]
    
    init(
      title: String? = nil,
      description: String? = nil,
      iconName: String? = nil,
      buttons: [ButtonConfiguration] = []
    ) {
      self.title = title
      self.description = description
      self.iconName = iconName
      self.buttons = buttons
    }
  }
}

extension EmptyView.Configuration {
  static func onboarding(
    createAccountAction: @Sendable @escaping () -> Void,
    showDemoAction: @Sendable @escaping () -> Void
  ) -> Self {
    .init(
      title: "Welcome to PaymentArchive blablabla bla bla bla",
      description: "Please create account to start.\nCheck out demo to see the app's features.",
      iconName: "person.crop.circle.badge.plus",
      buttons: [
        .init(
          title: "Create Account",
          action: createAccountAction
        ),
        .init(
          title: "Show Demo",
          action: showDemoAction
        )
      ]
    )
  }
  
  static func emptyArchive(
    addPaymentAction: @Sendable @escaping () -> Void
  ) -> Self {
    .init(
      title: "Your Archive is Empty",
      description: "Add your first payment to get best out of this app.",
      iconName: "clipboard",
      buttons: [
        .init(
          title: "Add Payment",
          action: addPaymentAction
        )
      ]
    )
  }
}
