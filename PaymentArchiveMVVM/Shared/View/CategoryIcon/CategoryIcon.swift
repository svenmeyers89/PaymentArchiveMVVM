//
//  CategoryIcon.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct CategoryIcon: View {
  struct Colors: Sendable {
    let iconBackground: Color
    let iconTint: Color
  }
  
  let iconSystemName: String
  let side: CGFloat
  let colors: Colors
  
  var body: some View {
    Image(systemName: iconSystemName)
      .resizable() // makes the image respect frame
      .scaledToFit()
      .frame(width: side, height: side)
      .foregroundColor(colors.iconTint)
      .padding(8) // internal image padding
      .background(colors.iconBackground)
      .clipShape(Circle())
  }
}

#Preview {
  CategoryIcon(
    iconSystemName: "plus.circle",
    side: 32,
    colors: .init(iconBackground: Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)), iconTint: .white)
  )
}
