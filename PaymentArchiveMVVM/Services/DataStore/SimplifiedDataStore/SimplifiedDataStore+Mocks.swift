//
//  SimplifiedDataStore+Mocks.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import Foundation

extension SimplifiedDataStore {
  static let empty = SimplifiedDataStore(accounts: [], payments: [:])
  
  static let demo = SimplifiedDataStore(accounts: [], payments: [:])

  static let singleAccountWithMultiplePayments: SimplifiedDataStore = {
    let account1Id = "1"
    let paymentTimestamps: [String] = [
      "20.3.2025. 16:45",
      "24.4.2025. 12:01",
      "24.4.2025. 13:13",
      "25.4.2025. 06:48",
      "5.5.2025. 12:33",
      "5.5.2025. 14:13",
      "7.5.2025. 08:21",
      "12.5.2025. 16:03",
      "12.5.2025. 18:45",
      "1.6.2025. 11:45",
      "2.6.2025. 06:48",
      "2.6.2025. 12:41",
      "4.6.2025. 10:12",
      "6.6.2025. 07:12"
    ]
    let currency = Currency.eur
    
    let account1 = Account(
      id: account1Id, name: "Perica's account",
      currency: currency,
      useBiometry: false
    )
    let payments: [String: Payment] = paymentTimestamps
      .reduce([:], { partialResult, paymentTimestamp in
        var updatedResult = partialResult
        updatedResult[paymentTimestamp] = Payment(
          id: paymentTimestamp,
          createdAt: paymentTimestamp.toDate(),
          accountId: account1Id,
          amountMinorUnits: Int(arc4random() % 1000),
          category: Payment.Category.allCases.randomElement()!
        )
        return updatedResult
      })
   
    return SimplifiedDataStore(
      accounts: [account1],
      payments: [account1.id: payments]
    )
  }()
}

fileprivate let dataFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "dd.MM.yyyy. HH:mm"
  return formatter
}()

fileprivate extension String {
  func toDate() -> Date {
    return dataFormatter.date(from: self)!
  }
}
