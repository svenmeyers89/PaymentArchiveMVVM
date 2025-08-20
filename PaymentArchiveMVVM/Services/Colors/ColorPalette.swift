//
//  ColorPalette.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 06.08.2025..
//

import SwiftUI

struct ColorPalette: Sendable, Equatable {
  struct Background: Sendable, Equatable {
    let primary: Color
    let header: Color
    let box: Color
  }

  struct Text: Sendable, Equatable {
    let primary: Color
    let secondary: Color
    let buttonTitle: Color
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

  let background: Background
  let text: Text
  let highlight: Highlight
  let selector: Selector
  let activityIndicator: ActivityIndicator
}
