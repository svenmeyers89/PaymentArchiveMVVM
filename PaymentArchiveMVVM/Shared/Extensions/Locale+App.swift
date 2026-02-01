//
//  Locale+App.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 13.01.2026..
//

import Foundation

extension Locale {
  static let appLocale: Locale = .autoupdatingCurrent
}

extension Calendar {
  static let appCalendar: Calendar = .autoupdatingCurrent
  
  func dayDifference(from startDate: Date, to endDate: Date) -> Int? {
    guard let diff = dateComponents(
      [.day],
      from: startOfDay(for: startDate),
      to: startOfDay(for: endDate)
    ).day else {
      return nil
    }
    return abs(diff)
  }
  
  func isDate(_ date: Date, inDayOf baseDate: Date) -> Bool {
    isDate(date, equalTo: baseDate, toGranularity: .day)
  }
  
  func isDate(_ date: Date, inMonthOf baseDate: Date) -> Bool {
    isDate(date, equalTo: baseDate, toGranularity: .month)
  }
}
