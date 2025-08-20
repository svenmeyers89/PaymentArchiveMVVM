//
//  ContentView.swift
//  PaymentArchiveMVVM
//
//  Created by Sven Majeric on 20.07.2025..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
          List {
            PaymentView(
              payment: .init(
                accountId: "1",
                amount: 12.5,
                category: .accomodation
              )
            )
          }
          .listStyle(.insetGrouped)
    }
}

#Preview {
    ContentView()
}
