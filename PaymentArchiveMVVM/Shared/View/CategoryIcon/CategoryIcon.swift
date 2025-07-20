//
//  CategoryIcon.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct CategoryIcon: View {
  let iconSystemName: String
  let side: CGFloat
  
  var body: some View {
    Image(systemName: iconSystemName)
      .resizable() // makes the image respect frame
      .scaledToFit() // prevents distortion
      .frame(width: side, height: side) // fixed icon size
      //.foregroundColor(colors.categoryIcon)
      .foregroundColor(.white)
      .padding(8) // internal padding
      //.background(colors.categoryBackground)
      .background(.blue)
      .clipShape(Circle())
  }
}

#Preview {
  CategoryIcon(iconSystemName: "plus.circle", side: 32)
}
