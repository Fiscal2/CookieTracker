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
    
    // State for Adding a New Order
    @State private var showAddOrderPopup = false
    @State private var chocolateChipQuantity = 0.0
    @State private var sprinkleQuantity = 0.0
    @State private var smoreQuantity = 0.0
    @State private var oreoQuantity = 0.0
    @State private var promisedDate = Date()
    @State private var isDelivery = false

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
                    DetailRow(label: "Email", value: customer.email ?? "N/A")
                        .frame(minWidth: 350, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
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
                
                Button(action: {
                    showAddOrderPopup = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                        Text("Add Order")
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

            // Orders Summary with Swipe-to-Delete
            Text("Orders Summary")
                .font(.headline)

            let ordersArray = Array(customer.orders as? Set<OrderEntity> ?? [])

            List {
                ForEach(ordersArray, id: \.self) { order in
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
                .onDelete(perform: deleteOrder) // Swipe-to-Delete
            }
            .frame(minHeight: 50, maxHeight: .infinity)
            .listStyle(PlainListStyle())

            Divider()
            
            
            // Orders List
            Text("Total Cookies")
                .font(.headline)
            
            // Calculate Total Cost (Includes Delivery Fee)
            let totalCost = ordersArray.TotalOrdersCost()
            
            let allOrderCookies = ordersArray.flatMap { order in
                (order.cookies as? Set<CookieEntity>) ?? []
            }
            
            let groupedCookies = Dictionary(grouping: allOrderCookies, by: { $0.flavor ?? "Unknown" })
                .mapValues { cookies in
                    cookies.reduce(0) { total, cookie in total + Int(cookie.quantity) }
                }
            
            let consolidatedCookies = groupedCookies.map { (flavor, quantity) in
                (flavor: flavor, quantity: quantity)
            }

            LazyVGrid(columns: lazyColumns, alignment: .leading, spacing: 16) {
                ForEach(consolidatedCookies, id: \.flavor) { cookie in
                    DetailRow(label: "\(cookie.flavor):", value: "\(cookie.quantity)")
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
                
                Button(action: {
                    saveCustomerChanges()
                    showEditCustomerPopup = false
                }) {
                   Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
        }
        
        // New Order Pop-Up
        .sheet(isPresented: $showAddOrderPopup) {
            VStack(spacing: 12) {
                Text("Add New Order")
                    .font(.headline)
                    .padding(.top)
                
                
                // Flavor Inputs
                FlavorInputRow(flavor: OrderConstants.chocolateChip, quantity: $chocolateChipQuantity)
                FlavorInputRow(flavor: OrderConstants.sprinkle, quantity: $sprinkleQuantity)
                FlavorInputRow(flavor: OrderConstants.smore, quantity: $smoreQuantity)
                FlavorInputRow(flavor: OrderConstants.oreo, quantity: $oreoQuantity)
                
                Divider()
                
                // Delivery & Promised Date
                LazyVGrid(columns: lazyColumns, alignment: .leading, spacing: 16) {
                    DatePicker("", selection: $promisedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    
                    Toggle(isOn: $isDelivery) {
                        Text("Delivery")
                    }
                    .toggleStyle(SwitchToggleStyle())
                }
                
                Divider()
                
                HStack {
                    Text("Total Cost:")
                        .font(.headline)
                    Spacer()
                    Text("$\(String(format: "%.2f", "0"))")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                Button(action: {
                    saveNewOrder()
                    showAddOrderPopup = false
                }) {
                   Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
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
                
                Button(action: {
                    saveNote()
                    showNotePopup = false
                }) {
                   Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
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
                    DetailRow(label: "\(cookie.flavor ?? ""):", value: "\(Int(cookie.quantity))")
                }
                
                if selectedOrderDelivery {
                    DetailRow(label: "Delivery Fee:", value: "$6")
                }

                Spacer()

                // Close Button
                Button(action: {
                    showOrderPopup = false
                }) {
                    Text("Close")
                        .frame(maxWidth: .infinity, minHeight: 21)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.medium]) // Half-screen pop-up
        }
    }
    
    // Save New Order Function
    private func saveNewOrder() {
            let newTotal = chocolateChipQuantity + sprinkleQuantity + smoreQuantity + oreoQuantity
            guard newTotal >= 6 else { return }

            let newOrder = OrderEntity(context: viewContext)
            newOrder.promisedDate = promisedDate
            newOrder.delivery = isDelivery
            newOrder.customer = customer

            let flavors = [
                (OrderConstants.chocolateChip, chocolateChipQuantity),
                (OrderConstants.sprinkle, sprinkleQuantity),
                (OrderConstants.smore, smoreQuantity),
                (OrderConstants.oreo, oreoQuantity)
            ]

            for (flavor, quantity) in flavors where quantity > 0 {
                let newCookie = CookieEntity(context: viewContext)
                newCookie.flavor = flavor
                newCookie.quantity = Double(quantity)
                newCookie.order = newOrder
            }

            try? viewContext.save()
        }
    
    private func deleteOrder(at offsets: IndexSet) {
            let ordersArray = Array(customer.orders as? Set<OrderEntity> ?? [])
            for index in offsets {
                let orderToDelete = ordersArray[index]
                viewContext.delete(orderToDelete)
            }
            try? viewContext.save()
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

