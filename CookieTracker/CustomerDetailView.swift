//
//  CustomerDetailView.swift
//  CookieTracker
//
import SwiftUI
import CoreData

struct CustomerDetailView: View {
    let customer: CustomerEntity
    @Environment(\.openURL) var openURL
    @State private var selectedOrderDate: Date? // Tracks tapped order date
    @State private var showOrderDetails = false // Controls pop-up visibility

    var totalCost: Double {
        let ordersArray = (customer.orders as? Set<OrderEntity>) ?? []
        let totalCookies = ordersArray.reduce(0) { $0 + Int($1.quantity) }
        let cookieCost = Double(totalCookies) * 2.5
        let deliveryFee = customer.delivery ? 6.0 : 0.0
        return cookieCost + deliveryFee
    }

    var groupedOrdersByDate: [(date: Date, totalCookies: Int, totalCost: Double)] {
        let ordersArray = (customer.orders as? Set<OrderEntity>) ?? []

        let ordersWithDates = ordersArray.compactMap { order -> (Date, OrderEntity)? in
            guard let promisedDate = order.promisedDate else { return nil }
            return (promisedDate, order)
        }

        let groupedDictionary = Dictionary(grouping: ordersWithDates, by: { $0.0 })

        return groupedDictionary
            .map { (date, groupedOrders) in
                let totalCookies = groupedOrders.reduce(0) { $0 + Int($1.1.quantity) }
                let totalCost = Double(totalCookies) * 2.5
                return (date: date, totalCookies: totalCookies, totalCost: totalCost)
            }
            .sorted { $0.date < $1.date }
    }

    var mergedOrders: [(flavor: String, quantity: Int)] {
        let ordersArray = (customer.orders as? Set<OrderEntity>) ?? []

        let groupedDictionary = Dictionary(grouping: ordersArray, by: { $0.flavor ?? "Unknown" })

        return groupedDictionary
            .map { (flavor, groupedOrders) in
                let totalQuantity = groupedOrders.reduce(0) { $0 + Int($1.quantity) }
                return (flavor: flavor, quantity: totalQuantity)
            }
            .sorted { $0.flavor < $1.flavor }
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
                Divider()
                if !groupedOrdersByDate.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Orders Summary")
                            .font(.headline)
                        ForEach(groupedOrdersByDate, id: \.date) { group in
                            HStack {
                                // 🔥 Make the order clickable
                                Button(action: {
                                    selectedOrderDate = group.date
                                    showOrderDetails = true
                                }) {
                                    Text("- \(group.totalCookies) cookies")
                                        .foregroundColor(.blue)
                                        .bold()
                                }
                                Spacer()
                                Text("$\(String(format: "%.2f", group.totalCost))")
                                    .bold()
                                    .foregroundColor(.blue)
                                Text("for \(formattedDate(group.date))")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }

            if !mergedOrders.isEmpty {
                Divider()
                Text("Orders")
                    .font(.headline)

                ForEach(mergedOrders, id: \.flavor) { order in
                    HStack {
                        Text("\(order.flavor):")
                        Spacer()
                        Text("\(order.quantity) cookies")
                    }
                }
            }

            if customer.delivery {
                Text("Delivery Fee: $6")
                    .foregroundColor(.blue)
            }

            Divider()

            HStack {
                Text("Total Cost:")
                    .font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", totalCost))")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showOrderDetails) {
            if let selectedDate = selectedOrderDate {
                OrderDetailPopupView(customer: customer, selectedDate: selectedDate)
            }
        }
    }

    private func openAddressInMaps(_ address: String) {
        let formattedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(formattedAddress)") {
            openURL(url)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}

// Order Detail Pop-Up
struct OrderDetailPopupView: View {
    let customer: CustomerEntity
    let selectedDate: Date
    @Environment(\.dismiss) var dismiss

    var ordersForDate: [(flavor: String, quantity: Int)] {
        let ordersArray = (customer.orders as? Set<OrderEntity>) ?? []

        let filteredOrders = ordersArray.filter { $0.promisedDate == selectedDate }

        let groupedDictionary = Dictionary(grouping: filteredOrders, by: { $0.flavor ?? "Unknown" })

        return groupedDictionary
            .map { (flavor, groupedOrders) in
                let totalQuantity = groupedOrders.reduce(0) { $0 + Int($1.quantity) }
                return (flavor: flavor, quantity: totalQuantity)
            }
            .sorted { $0.flavor < $1.flavor }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Order Details for \(formattedDate(selectedDate))")
                .font(.headline)
                .padding()

            if !ordersForDate.isEmpty {
                ForEach(ordersForDate, id: \.flavor) { order in
                    HStack {
                        Text(order.flavor)
                        Spacer()
                        Text("\(order.quantity) cookies")
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No orders found for this date.")
                    .foregroundColor(.gray)
            }

            Spacer()

            Button("Close") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
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



// Date Formatter for displaying the "Promised By" date
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}





