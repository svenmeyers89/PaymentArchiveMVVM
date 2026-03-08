//
//  PaymentArchiveView+AddOns.swift
//  PaymentArchiveMVVM
//

extension PaymentArchiveView {
  enum ContentType {
    case loading
    case onboarding
    case listView(
      sections: [PaymentGroup],
      currency: Currency,
      selectedAccountId: String
    )
    case error(String)
  }

  enum Modal {
    case updateAccount(EditAccountUseCase)
    case updatePayment(EditPaymentUseCase)
    case changeTheme
    case filterPaymentCategories
  }
}
