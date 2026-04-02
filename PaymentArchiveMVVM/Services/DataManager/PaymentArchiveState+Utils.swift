//
//  PaymentArchiveState.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 14.01.2026..
//

extension PaymentArchive.State {
  static let empty = PaymentArchive.State(selectedAccountId: nil, accounts: [:], payments: [:], isDemoMode: false)
  
  var selectedAccount: Account? {
    guard let selectedAccountId else { return nil }
    return accounts[selectedAccountId]
  }
}
