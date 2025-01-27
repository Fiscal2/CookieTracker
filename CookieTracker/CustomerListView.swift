//
//  CustomerListView.swift
//  CookieTracker
//
//  Created by Zachary Goldberg on 1/26/25.
//
import SwiftUI

struct CustomerListView: View {
    @Binding var customers: [Customer]
    @State private var searchText = ""

    // Filtered list of customers based on the search query
    var filteredCustomers: [Customer] {
        customers.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            List {
                if filteredCustomers.isEmpty {
                    Text("No customers yet. Add them in the Orders section.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ForEach(filteredCustomers) { customer in
                        NavigationLink(destination: CustomerDetailView(customer: customer)) {
                            HStack {
                                Text(customer.name)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Customers")
            .searchable(text: $searchText, prompt: "Search customers") // Built-in search bar
        }
    }
}




