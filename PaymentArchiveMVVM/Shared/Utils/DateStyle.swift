//
//  DateStyle.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 13.01.2026..
//

import Foundation

enum DateStyle {
  static let dateTime = Date.FormatStyle()
    .year()
    .month(.abbreviated)
    .day()
    .hour()
    .minute()
    .locale(Locale.appLocale)
}
