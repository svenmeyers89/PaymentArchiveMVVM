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
  let colors: Colors

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
                side: 20,
                colors: colors.categoryIcon
              )
              Text(category.rawValue)
                .font(.caption)
                .foregroundStyle(colors.categoryTitle)
                .lineLimit(2)
            }
            .padding(8)
            .background(colors.categoryBackground)
            .cornerRadius(12)
          }
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(
                selectedCategory == category ?
                colors.selectedCategoryBorder :
                .clear,
                lineWidth: 4
              )
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

extension CategorySelector {
  struct Colors: Sendable {
    let categoryIcon: CategoryIcon.Colors
    let categoryTitle: Color
    let categoryBackground: Color
    let selectedCategoryBorder: Color
  }
}

#Preview {
  @Previewable @State var selectedCategory: Payment.Category? = nil
  CategorySelector(
    selectedCategory: $selectedCategory,
    categories: Payment.Category.allCases,
    colors: .init(
      categoryIcon: .init(
        iconBackground: .blue,
        iconTint: .white
      ),
      categoryTitle: .black,
      categoryBackground: .gray,
      selectedCategoryBorder: .yellow
    )
  )
}
