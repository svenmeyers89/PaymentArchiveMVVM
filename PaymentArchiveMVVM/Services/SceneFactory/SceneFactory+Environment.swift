//
//  SceneFactory+Environment.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 23.08.2025..
//

import SwiftUI

private struct SceneFactoryKey: EnvironmentKey {
  static var defaultValue: SceneFactory? {
    //fatalError("SceneFactory not set. Make sure to inject it at app launch.")
    return nil
  }
}

extension EnvironmentValues {
  var sceneFactory: SceneFactory? {
    get { self[SceneFactoryKey.self] }
    set { self[SceneFactoryKey.self] = newValue }
  }
}
