//
//  CustomerDetailView.swift
//  CookieTracker
//
//  Created by Zachary Goldberg on 1/26/25.
//

import SwiftUI

struct CustomerDetailView: View {
    let customer: Customer
    @Environment(\.openURL) var openURL // Environment to handle URL opening

    // Calculate the total cost of the customer's order
    var totalCost: Double {
        let totalCookies = customer.orders.reduce(0) { $0 + $1.quantity }
        let cookieCost = (totalCookies / 12) * 30 + (totalCookies % 12 > 0 ? 15 : 0)
        let deliveryFee = customer.delivery ? 6 : 0
        return Double(cookieCost + deliveryFee)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customer Details")
                .font(.largeTitle)
                .bold()

            // Customer Information
            Group {
                DetailRow(label: "Name", value: customer.name)
                DetailRow(label: "Phone", value: customer.phone)
                DetailRow(label: "Email", value: customer.email)

                // Make the address clickable
                HStack {
                    Text("Address")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        openAddressInMaps(customer.address)
                    }) {
                        Text(customer.address)
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
                .padding(.vertical, 4)
            }

            Divider()

            // Order Details
            Text("Orders")
                .font(.headline)

            if customer.orders.isEmpty {
                Text("No orders placed.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(customer.orders, id: \.flavor) { order in
                    HStack {
                        Text("\(order.flavor):")
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




