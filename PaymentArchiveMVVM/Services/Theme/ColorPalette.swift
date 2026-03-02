//
//  ColorPalette.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

struct ColorPalette: Sendable, Equatable {
  struct Text: Sendable, Equatable {
    let primary: Color
    let secondary: Color
    let link: Color
    let caption: Color
  }
  
  struct Highlight: Sendable, Equatable {
    let tint: Color
    let icon: Color
    let title: Color
  }
  
  struct Selector: Sendable, Equatable {
    let title: Color
    let background: Color
    let border: Color
  }
  
  struct ActivityIndicator: Sendable, Equatable {
    let tint: Color
  }
  
  struct Toggle: Sendable, Equatable {
    let tint: Color
  }

  let text: Text
  let highlight: Highlight
  let selector: Selector
  let activityIndicator: ActivityIndicator
  let toggle: Toggle
}
