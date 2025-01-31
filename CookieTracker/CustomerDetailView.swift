//
//  CustomerDetailView.swift
//  CookieTracker
//
import SwiftUI
import CoreData

struct CustomerDetailView: View {
    let customer: CustomerEntity
    @Environment(\.openURL) var openURL

    // Compute total cost by consolidating orders
    var totalCost: Double {
        let consolidatedOrders = consolidateOrders()
        let totalCookies = consolidatedOrders.reduce(0) { $0 + $1.value }
        let cookieCost = Double(totalCookies) * 2.5
        let deliveryFee = customer.delivery ? 6.0 : 0.0
        return cookieCost + deliveryFee
    }

    // Function to consolidate orders by flavor
    private func consolidateOrders() -> [String: Int] {
        var orderSummary: [String: Int] = [:]
        
        if let ordersSet = customer.orders as? Set<OrderEntity> {
            for order in ordersSet {
                let flavor = order.flavor ?? "Unknown Flavor"
                orderSummary[flavor, default: 0] += Int(order.quantity)
            }
        }
        return orderSummary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customer Details")
                .font(.largeTitle)
                .bold()

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

            let consolidatedOrders = consolidateOrders()

            if consolidatedOrders.isEmpty {
                Text("No orders placed.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(consolidatedOrders.sorted(by: { $0.key < $1.key }), id: \.key) { flavor, quantity in
                    HStack {
                        Text("\(flavor):")
                        Spacer()
                        Text("\(quantity) cookies")
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






