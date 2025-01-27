//
//  ContentView.swift
//  CookieTracker
//
//  Created by Zachary Goldberg on 1/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var customers: [Customer] = []

    var body: some View {
        TabView {
            CustomerListView(customers: $customers)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Customers")
                }
            OrderView(customers: $customers)
                .tabItem {
                    Image(systemName: "cart")
                    Text("Orders")
                }
            Text("Settings")
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}
