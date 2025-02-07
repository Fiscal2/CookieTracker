import SwiftUI
import CoreData

struct CustomerDetailView: View {
    @ObservedObject var customer: CustomerEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) var openURL

    // State for Editing Customer
    @State private var showEditCustomerPopup = false

    // State for Order Notes
    @State private var showNotePopup = false
    @State private var noteText = ""
    
    // State for Adding a New Order
    @State private var showAddOrderPopup = false
    @State private var cookieSelections: [String: Double] = [
        OrderConstants.chocolateChip: 0,
        OrderConstants.sprinkle: 0,
        OrderConstants.smore: 0,
        OrderConstants.oreo: 0
    ]
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
    private var newOrderTotalQuantity: Double {
        cookieSelections.values.reduce(0, +)
    }
    
    private var newOrderTotalCost: Double {
        let deliveryFee = isDelivery ? OrderConstants.deliveryFee : 0.0
        return (newOrderTotalQuantity * OrderConstants.cookiePrice) + deliveryFee
    }
    private var isValidNewOrder: Bool {
        return newOrderTotalQuantity >= 6
    }

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
                
                // "Add Order" Button
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

            let inProgressOrders = Array(customer.orders as? Set<OrderEntity> ?? []).inProgressOrders()
            
            List {
                ForEach(inProgressOrders, id: \.self) { order in
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
                        Text("For \(orderPromisedDate.formattedDateTime())")
                            .foregroundColor(.gray)
                    }
                }
                .onDelete { offsets in
                    if let index = offsets.first {
                        let orderToDelete = inProgressOrders[index]
                        deleteOrder(orderToDelete: orderToDelete)
                    }
                }
            }
            .frame(minHeight: 50, maxHeight: .infinity)
            .listStyle(PlainListStyle())

            Divider()
            
            // Orders List
            Text("Total Cookies")
                .font(.headline)
                        
            let cookiesFromAllOrders = inProgressOrders.flatMap { order in
                (order.cookies as? Set<CookieEntity>) ?? []
            }
            
            let groupedCookies = Dictionary(grouping: cookiesFromAllOrders, by: { $0.flavor ?? "Unknown" })
                .mapValues { cookies in
                    cookies.reduce(0) { total, cookie in
                        total + Int(cookie.quantity)
                    }
                }
            
            LazyVGrid(columns: lazyColumns, alignment: .leading, spacing: 16) {
                ForEach(groupedCookies.keys.sorted(), id: \.self) { flavor in
                    if let quantity = groupedCookies[flavor] {
                        DetailRow(label: "\(flavor):", value: "\(quantity)")
                    }
                }
            }

            Divider()

            // Total Cost of All Orders for Customer
            HStack {
                Text("Total Cost:")
                    .font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", inProgressOrders.TotalOrdersCost()))")
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

                TextField("Name", text: Binding(
                    get: { customer.name ?? "" },
                    set: { customer.name = $0 }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Phone", text: Binding(
                    get: { customer.phone ?? "" },
                    set: { customer.phone = $0 }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Email", text: Binding(
                    get: { customer.email ?? "" },
                    set: { customer.email = $0 }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Address", text: Binding(
                    get: { customer.address ?? "" },
                    set: { customer.address = $0 }
                ))
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
                ForEach(cookieSelections.keys.sorted(), id: \.self) { flavor in
                    FlavorInputRow(flavor: flavor, quantity: Binding(
                        get: { cookieSelections[flavor, default: 0] },
                        set: { cookieSelections[flavor] = $0 }
                    ))
                }
                
                Divider()
                
                // Delivery & Promised Date
                LazyVGrid(columns: lazyColumns, alignment: .leading, spacing: 16) {
                    DatePicker("", selection: $promisedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    
                    Toggle(isOn: $isDelivery) {
                        Text("Delivery")
                            .padding(.leading, 40)
                    }
                    .toggleStyle(SwitchToggleStyle())
                }
                
                Divider()
                
                HStack {
                    Text("Total Cost:")
                        .font(.headline)
                    Spacer()
                    Text("$\(String(format: "%.2f", newOrderTotalCost))")
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

        // Order Note Pop-Up
        .sheet(isPresented: $showNotePopup) {
            VStack(spacing: 8) {
                Text("Order Note")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: $noteText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()
                
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
                Text("Order Details for \(selectedOrderDate.formattedDateTime())")
                    .font(.headline)
                    .padding(.top)

                // Delivery Status
                HStack {
                    Text(selectedOrderDelivery ? "🏠 Home Delivery" : "🚗 Pickup")
                        .foregroundColor(.blue)
                        .bold()
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
    
    private func saveNewOrder() {
        guard isValidNewOrder else { return }
        customer.createNewOrder(promisedDate: promisedDate, isDelivery: isDelivery, cookieSelections: cookieSelections, context: viewContext)
        // reset state
        cookieSelections = cookieSelections.mapValues { _ in 0 }
        isDelivery = false
        promisedDate = Date()
    }
    
    private func deleteOrder(orderToDelete: OrderEntity) {
        customer.deleteOrder(order: orderToDelete, context: viewContext)
    }

    private func saveCustomerChanges() {
        try? viewContext.save()
    }

    private func saveNote() {
        customer.note = noteText
        try? viewContext.save()
    }
    
    private func markOrderAsComplete(_ order: OrderEntity) {
        order.isCompleted = true
        try? viewContext.save()
    }

    private func openAddressInMaps(_ address: String) {
        let formattedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(formattedAddress)") {
            openURL(url)
        }
    }
}
