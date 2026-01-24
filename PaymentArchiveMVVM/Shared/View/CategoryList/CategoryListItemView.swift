//
//  CategoryListItemView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.01.2026..
//

import SwiftUI

struct CategoryListItemView: View {
  enum ItemType {
    case allCategories
    case paymentCategory(
      Payment.Category,
      categoryIconColors: CategoryIcon.Colors
    )
    
    fileprivate func title(isSelected: Bool) -> String {
      switch self {
      case .allCategories:
        if isSelected {
          "Unselect All Categories"
        } else {
          "Select All Categories"
        }
      case .paymentCategory(let category, _):
        "\(category.rawValue)"
      }
    }
  }
  
  struct Colors {
    let title: Color
    let background: Color
    let toggle: Color
  }
  
  let itemType: ItemType
  let colors: Colors
  @Binding var isSelected: Bool
  
  private var categoryIcon: CategoryIcon? {
    if case .paymentCategory(let paymentCategory, let categoryIconColors) = itemType {
      return CategoryIcon(
        iconSystemName: paymentCategory.symbolName,
        side: 24,
        colors: categoryIconColors
      )
    } else {
      return nil
    }
  }
  
  var body: some View {
    HStack(spacing: 12) {
      categoryIcon
      
      Text(itemType.title(isSelected: isSelected))
        .font(.headline)
        .foregroundStyle(colors.title)
      
      Toggle("", isOn: $isSelected)
        .tint(colors.toggle)
    }
    .background(colors.background)
  }
}

#Preview {
  @Previewable @State var isSelected: Bool = false
  let systemColors = ColorPalette.system
  
  VStack {
    CategoryListItemView(
      itemType: .allCategories,
      colors: .init(
        title: systemColors.text.primary,
        background: systemColors.background.primary,
        toggle: systemColors.toggle.tint
      ),
      isSelected: $isSelected
    )
    CategoryListItemView(
      itemType: .paymentCategory(
        .accommodation,
        categoryIconColors: .init(
          iconBackground: systemColors.highlight.tint,
          iconTint: systemColors.highlight.icon
        )
      ),
      colors: .init(
        title: systemColors.text.primary,
        background: systemColors.background.primary,
        toggle: systemColors.toggle.tint
      ),
      isSelected: $isSelected
    )
  }
}
