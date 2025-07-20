//
//  CategorySelector.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct CategorySelector: View {
  @Binding var selectedCategory: Payment.Category?
  let categories: [Payment.Category]
  //let colors: EditPaymentColors.HorizontalSelector

  var body: some View {
    ScrollView(.horizontal, showsIndicators: true) {
      LazyHStack(spacing: 20) {
        ForEach(categories, id: \.self) { category in
          Button(action: {
            selectedCategory = category
          }) {
            VStack {
              CategoryIcon(
                iconSystemName: category.symbolName,
                side: 20
              )
              Text(category.name)
                .font(.caption)
                //.foregroundStyle(colors.title)
                .foregroundStyle(.black)
                .lineLimit(2)
            }
            .padding(8)
            //.background(colors.background)
            .background(.gray)
            .cornerRadius(12)
          }
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              //.stroke(selectedCategory == item ? colors.iconBorder : Color.clear, lineWidth: 2)
              .stroke(selectedCategory == category ? .yellow : .clear, lineWidth: 4)
          )
        }
      }
      .padding(.horizontal)
      // Need bottom and top padding so that buttons are not clipped when highlighted or when scrolled
      .padding(.bottom, 16)
      .padding(.top, 8)
    }
  }
}

#Preview {
  @Previewable @State var selectedCategory: Payment.Category? = nil
  CategorySelector(
    selectedCategory: $selectedCategory,
    categories: Payment.Category.allCases
  )
}
