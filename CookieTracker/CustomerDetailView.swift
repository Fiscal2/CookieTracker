//
//  CustomerDetailView.swift
//  CookieTracker
//
import SwiftUI
import CoreData

struct CustomerDetailView: View {
    let customer: CustomerEntity
    @Environment(\.openURL) var openURL

    // State for notes
    @State private var showNotePopup = false
    @State private var noteText = ""
    @State private var noteTooLong = false

    // State for order details pop-up
    @State private var showOrderPopup = false
    @State private var selectedOrderDetails: [(String, Int)] = []
    @State private var selectedOrderDate: Date = Date()
    @State private var selectedOrderDelivery: Bool = false

    var totalCost: Double {
        let ordersArray = (customer.orders as? Set<OrderEntity>) ?? []
        let totalCookies = ordersArray.reduce(0) { $0 + Int($1.quantity) }
        let cookieCost = Double(totalCookies) * 2.5
        let deliveryFee = customer.delivery ? 6.0 : 0.0
        return cookieCost + deliveryFee
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with Floating "Write Note" Button
            HStack {
                Text("Customer Details")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                // Floating "Write Note" Button
                Button(action: {
                    noteText = customer.note ?? ""
                    showNotePopup = true
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Circle())
                }
            }

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

            // Orders Summary
            Text("Orders Summary")
                .font(.headline)

            let ordersArray = (customer.orders as? Set<OrderEntity>) ?? []
            let groupedOrders = Dictionary(grouping: ordersArray, by: { $0.promisedDate ?? Date() })
            
            ForEach(groupedOrders.sorted(by: { $0.key < $1.key }), id: \.key) { date, orders in
                let totalCookies = orders.reduce(0) { $0 + Int($1.quantity) }
                let totalCost = Double(totalCookies) * 2.5

                HStack {
                    Button(action: {
                        selectedOrderDetails = orders.map { ($0.flavor ?? "Unknown", Int($0.quantity)) }
                        selectedOrderDate = date
                        selectedOrderDelivery = customer.delivery
                        showOrderPopup = true
                    }) {
                        Text("- \(totalCookies) cookies")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Text("$\(String(format: "%.2f", totalCost))")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("for \(formattedDate(date))")
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // Orders List
            Text("Total Cookies")
                .font(.headline)

            let consolidatedOrders = Dictionary(grouping: ordersArray, by: { $0.flavor ?? "Unknown" })
                .mapValues { $0.reduce(0) { $0 + Int($1.quantity) } }

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

            Spacer()
        }
        .padding()
        
        // Note Pop-Up
        .sheet(isPresented: $showNotePopup) {
            VStack(spacing: 8) {
                Text("Order Note (Max 10 Words)")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: $noteText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()
                    .onChange(of: noteText) {
                        checkWordLimit()
                    }

                if noteTooLong {
                    Text("⚠️ Note cannot exceed 10 words.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.bottom, 5)
                }

                Button("Save") {
                    if !noteTooLong {
                        saveNote()
                        showNotePopup = false
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(noteTooLong ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .disabled(noteTooLong)
                .contentShape(Rectangle()) // Ensures full button is tappable

                Spacer()
            }
            .padding()
            .presentationDetents([.medium]) // Half-screen pop-up
        }
        
        // Order Details Pop-Up (For Clicking "12 Cookies, 6 Cookies, etc.")
        .sheet(isPresented: $showOrderPopup) {
            VStack(spacing: 12) {
                Text("Order Details for \(formattedDate(selectedOrderDate))")
                    .font(.headline)
                    .padding(.top)

                // Delivery Status
                if selectedOrderDelivery {
                    HStack {
                        Text("🏠 Home Delivery")
                            .foregroundColor(.blue)
                            .bold()
                    }
                } else {
                    HStack {
                        Text("🚗 Pickup")
                            .foregroundColor(.blue)
                            .bold()
                    }
                }

                Divider()

                // List of Flavors & Quantities
                ForEach(selectedOrderDetails, id: \.0) { flavor, quantity in
                    HStack {
                        Text(flavor)
                        Spacer()
                        Text("\(quantity) cookies")
                    }
                }

                Spacer()

                // Close Button
                Button("Close") {
                    showOrderPopup = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .contentShape(Rectangle()) // Ensures full button is tappable

            }
            .padding()
            .presentationDetents([.medium]) // Half-screen pop-up
        }
    }

    private func checkWordLimit() {
        let words = noteText.split(separator: " ").count
        noteTooLong = words > 10
    }

    private func saveNote() {
        customer.note = noteText
        try? customer.managedObjectContext?.save()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }

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




// Date Formatter for displaying the "Promised By" date
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}





