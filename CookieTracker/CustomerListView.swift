//
//  CustomerListView.swift
//  CookieTracker
//
//  Created by Zachary Goldberg on 1/26/25.
//
import SwiftUI
import CoreData

struct CustomerListView: View {
    @FetchRequest(
        entity: CustomerEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomerEntity.name, ascending: true)]
    ) private var customers: FetchedResults<CustomerEntity>

    @State private var searchText = ""

    var filteredCustomers: [CustomerEntity] {
        customers.filter { searchText.isEmpty || ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false) }
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
                    ForEach(filteredCustomers, id: \.self) { customer in
                        NavigationLink(destination: CustomerDetailView(customer: customer)) {
                            HStack {
                                Text(customer.name ?? "Unknown Name")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Customers")
            .searchable(text: $searchText, prompt: "Search customers")
        }
    }
}





