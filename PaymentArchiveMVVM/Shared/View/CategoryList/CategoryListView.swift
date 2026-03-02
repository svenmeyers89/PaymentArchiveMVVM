//
//  CategoryListView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.01.2026..
//

import Foundation
import SwiftUI

struct CategoryListView: View {
  struct Colors {
    let categoryIcon: CategoryIcon.Colors
    let categoryListItem: CategoryListItemView.Colors
  }
  
  @State private var selectedPaymentCategories: Set<Payment.Category>
  @Environment(\.dismiss) var dismiss
  
  private let allPaymentCategories: [Payment.Category]
  private let colors: Colors
  private let onSave: (Set<Payment.Category>) -> Void

  init(
    allPaymentCategories: [Payment.Category],
    selectedPaymentCategories: Set<Payment.Category>,
    colors: Colors,
    onSave: @escaping (Set<Payment.Category>) -> Void
  ) {
    self._selectedPaymentCategories = State(initialValue: selectedPaymentCategories)
    self.allPaymentCategories = allPaymentCategories
    self.colors = colors
    self.onSave = onSave
  }
  
  var body: some View {
    List {
      Section {
        CategoryListItemView(
          itemType: .allCategories,
          colors: colors.categoryListItem,
          isSelected: Binding<Bool>(
            get: { selectedPaymentCategories == Set<Payment.Category>(allPaymentCategories) },
            set: { isSelected in
              if isSelected {
                selectedPaymentCategories = Set<Payment.Category>(allPaymentCategories)
              } else {
                selectedPaymentCategories.removeAll()
              }
            }
          ))
      }
      
      Section {
        ForEach(allPaymentCategories, id: \.rawValue) { paymentCategory in
          CategoryListItemView(
            itemType: .paymentCategory(paymentCategory, categoryIconColors: colors.categoryIcon),
            colors: colors.categoryListItem,
            isSelected: Binding<Bool>(
              get: { selectedPaymentCategories.contains(paymentCategory) },
              set: { isSelected in
                if isSelected {
                  selectedPaymentCategories.insert(paymentCategory)
                } else {
                  selectedPaymentCategories.remove(paymentCategory)
                }
              }
            )
          )
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Save") {
          onSave(selectedPaymentCategories)
          dismiss()
        }
        .disabled(selectedPaymentCategories.isEmpty)
      }
      
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    CategoryListView(
      allPaymentCategories: [.accommodation, .groceries, .presents, .restaurantsAndBars],
      selectedPaymentCategories: Set<Payment.Category>([.accommodation]),
      colors: .init(
        categoryIcon: .init(iconBackground: .green, iconTint: .white),
        categoryListItem: .init(title: .black, toggle: .blue)
      )
    ) { selectedPaymentCategories in
      print("Selected categories: \(selectedPaymentCategories)")
    }
  }
}
