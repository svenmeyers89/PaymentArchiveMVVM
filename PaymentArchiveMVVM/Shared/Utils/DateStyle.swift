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
  
  static let timeOnly: DateFormatter = {
    let f = DateFormatter()
    f.timeStyle = .short
    f.dateStyle = .none
    return f
  }()

  static let weekdayDayMonth: DateFormatter = {
    let f = DateFormatter()
    f.setLocalizedDateFormatFromTemplate("EEEE d MMM")
    return f
  }()

  static let monthYear: DateFormatter = {
    let f = DateFormatter()
    f.setLocalizedDateFormatFromTemplate("LLLL yyyy")
    return f
  }()
}
