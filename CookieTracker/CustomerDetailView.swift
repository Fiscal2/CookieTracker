//
//  CustomerDetailView.swift
//  CookieTracker
//
//  
//

import SwiftUI
import CoreData

struct CustomerDetailView: View {
    let customer: CustomerEntity
    @Environment(\.openURL) var openURL // Environment to handle URL opening

    // Calculate the total cost of the customer's order
    var totalCost: Double {
        // Safely convert orders to an array
        let ordersArray = (customer.orders as? Set<OrderEntity>)?.compactMap { $0 } ?? []

        // Calculate total cookies
        let totalCookies = ordersArray.reduce(0) { $0 + Int($1.quantity) }
        
        // Cookie cost calculation ($2.50 per cookie)
        let cookieCost = Double(totalCookies) * 2.5
        
        // Delivery fee (if applicable)
        let deliveryFee = customer.delivery ? 6.0 : 0.0
        
        return cookieCost + deliveryFee
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customer Details")
                .font(.largeTitle)
                .bold()

            // Customer Information
            Group {
                DetailRow(label: "Name", value: customer.name ?? "N/A")
                DetailRow(label: "Phone", value: customer.phone ?? "N/A")
                DetailRow(label: "Email", value: customer.email ?? "N/A")

                if let address = customer.address, !address.isEmpty {
                    HStack {
                        Text("Address")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            openAddressInMaps(address)
                        }) {
                            Text(address)
                                .foregroundColor(.blue)
                                .bold()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Divider()

            // Order Details
            Text("Orders")
                .font(.headline)

            // Ensure orders exist before iterating
            if let ordersSet = customer.orders as? Set<OrderEntity>, !ordersSet.isEmpty {
                let ordersArray = ordersSet.sorted { $0.flavor ?? "" < $1.flavor ?? "" } // Sort alphabetically
                ForEach(ordersArray, id: \.flavor) { order in
                    HStack {
                        Text("\(order.flavor ?? "Unknown Flavor"):")
                        Spacer()
                        Text("\(order.quantity) cookies")
                    }
                }

                Divider()

                if customer.delivery {
                    Text("Delivery Fee: $6")
                        .foregroundColor(.blue)
                }

                Divider()

                // Total Cost
                HStack {
                    Text("Total Cost:")
                        .font(.headline)
                    Spacer()
                    Text("$\(String(format: "%.2f", totalCost))")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            } else {
                Text("No orders placed.")
                    .foregroundColor(.gray)
                    .italic()
            }

            Spacer()
        }
        .padding()
    }

    // Function to open the address in Apple Maps
    private func openAddressInMaps(_ address: String) {
        let formattedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(formattedAddress)") {
            openURL(url)
        }
    }
}

// A reusable view for customer detail rows
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}






