//
//  ScreenFactory+Environment.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 23.08.2025..
//

import SwiftUI

private struct ScreenFactoryKey: EnvironmentKey {
  static var defaultValue: ScreenFactory? {
    //fatalError("ScreenFactory not set. Make sure to inject it at app launch.")
    return nil
  }
}

extension EnvironmentValues {
  var screenFactory: ScreenFactory? {
    get { self[ScreenFactoryKey.self] }
    set { self[ScreenFactoryKey.self] = newValue }
  }
}
