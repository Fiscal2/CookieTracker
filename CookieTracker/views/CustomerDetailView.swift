//
//  CustomerDetailView.swift
//  CookieTracker
//
import SwiftUI
import CoreData

struct CustomerDetailView: View {
    let customer: CustomerEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) var openURL

    // State for Editing Customer
    @State private var showEditCustomerPopup = false
    @State private var editedName = ""
    @State private var editedPhone = ""
    @State private var editedEmail = ""
    @State private var editedAddress = ""

    // State for Order Notes
    @State private var showNotePopup = false
    @State private var noteText = ""
    @State private var noteTooLong = false

    // State for Order Details Pop-Up
    @State private var showOrderPopup = false
    @State private var selectedCookieOrderDetails: [CookieEntity] = []
    @State private var selectedOrderDate: Date = Date()
    @State private var selectedOrderDelivery: Bool = false

    var lazyColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with Floating "Edit Customer" Button
            HStack {
                Text("Customer Details")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                // Floating "Edit Customer" Button
                Button(action: {
                    editedName = customer.name ?? ""
                    editedPhone = customer.phone ?? ""
                    editedEmail = customer.email ?? ""
                    editedAddress = customer.address ?? ""
                    showEditCustomerPopup = true
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
                LazyVGrid(columns: lazyColumns, alignment: .leading, spacing: 18) {
                    DetailRow(label: "Name", value: customer.name ?? "N/A")
                    DetailRow(label: "Phone", value: customer.phone ?? "N/A")
                    DetailRow(label: "Email", value: customer.email ?? "N/A").frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)

                }

                if let address = customer.address, !address.isEmpty {
                    HStack {
                        Text("Address")
                            .font(.headline)

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

                // "Order Note" Button
                Button(action: {
                    noteText = customer.note ?? ""
                    showNotePopup = true
                }) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.blue)
                        Text("Order Note")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Divider()

            // Orders Summary
            Text("Orders Summary")
                .font(.headline)

            let ordersArray = Array(customer.orders as? Set<OrderEntity> ?? [])
            ForEach(ordersArray, id: \.self){order in
                let orderPromisedDate = order.promisedDate ?? Date()
                let cookiesArray = Array(order.cookies as? Set<CookieEntity> ?? [])
                HStack {
                    Button(action: {
                        selectedCookieOrderDetails = cookiesArray
                        selectedOrderDate = orderPromisedDate
                        showOrderPopup = true
                        selectedOrderDelivery = order.delivery
                        
                    }) {
                        Text("\(order.TotalCookiesInOrder()) cookies")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Text("$\(String(format: "%.2f", order.TotalOrderCost()))")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("for \(formattedDate(orderPromisedDate))")
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // Orders List
            Text("Total Cookies")
                .font(.headline)
            
            // Calculate Total Cost (Includes Delivery Fee)
            let totalCost = ordersArray.TotalOrdersCost() + (ordersArray.contains { $0.delivery } ? 6.0 : 0.0)
            
            let allOrderCookies = ordersArray.flatMap { order in
                (order.cookies as? Set<CookieEntity>) ?? []
            }

            LazyVGrid(columns: lazyColumns, alignment: .leading, spacing: 16) {
                ForEach(allOrderCookies) { cookie in
                    DetailRow(label: "\(cookie.flavor ?? ""):", value: "\(cookie.quantity)")
                }
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

        // Edit Customer Pop-Up
        .sheet(isPresented: $showEditCustomerPopup) {
            VStack(spacing: 8) {
                Text("Edit Customer")
                    .font(.headline)
                    .padding(.top)

                TextField("Name", text: $editedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Phone", text: $editedPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Email", text: $editedEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Address", text: $editedAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Save") {
                    saveCustomerChanges()
                    showEditCustomerPopup = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
        }

        // Order Note Pop-Up**
        .sheet(isPresented: $showNotePopup) {
            VStack(spacing: 8) {
                Text("Order Note (Max 10 Words)")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: $noteText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()
                
                if noteTooLong {
                    Text("⚠️ Note cannot exceed 10 words.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.bottom, 5)
                }

                Button("Save") {
                    saveNote()
                    showNotePopup = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
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
                ForEach(selectedCookieOrderDetails) { cookie in
                    DetailRow(label: "\(cookie.flavor ?? ""):", value: "\(cookie.quantity)")
                }
                
                if selectedOrderDelivery {
                    DetailRow(label: "Delivery Fee:", value: "$6")
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

    private func saveCustomerChanges() {
        customer.name = editedName
        customer.phone = editedPhone
        customer.email = editedEmail
        customer.address = editedAddress
        try? viewContext.save()
    }

    private func saveNote() {
        customer.note = noteText
        try? viewContext.save()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    private func openAddressInMaps(_ address: String) {
        let formattedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(formattedAddress)") {
            openURL(url)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Text(value)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}
