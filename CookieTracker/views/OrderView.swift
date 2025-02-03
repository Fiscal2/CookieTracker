//
//  OrderView.swift
//  CookieTracker
//
//
//
import SwiftUI
import CoreData

struct OrderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: CustomerEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomerEntity.name, ascending: true)]
    ) private var customers: FetchedResults<CustomerEntity>

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var chocolateChipQuantity = 0.0
    @State private var sprinkleQuantity = 0.0
    @State private var smoreQuantity = 0.0
    @State private var oreoQuantity = 0.0
    @State private var isNewCustomer = true
    @State private var showSuccessMessage = false
    @State private var showValidationError = false
    @State private var promisedDate = Date()
    @State private var keyboardOffset: CGFloat = 0
    @State private var isDelivery = false
    
    private var currentTotalQuantity: Double {
        chocolateChipQuantity + sprinkleQuantity + smoreQuantity + oreoQuantity
    }
    private var cookieSelections: [(flavor: String, quantity: Double)] {
        return [
            (OrderConstants.chocolateChip, chocolateChipQuantity),
            (OrderConstants.sprinkle, sprinkleQuantity),
            (OrderConstants.smore, smoreQuantity),
            (OrderConstants.oreo, oreoQuantity)
        ]
    }

    var totalCost: Double {
        let cookieCost = Double(currentTotalQuantity) * 2.5
        let deliveryFee = isDelivery ? 6.0 : 0.0
        return cookieCost + deliveryFee
    }

    private var isValidOrder: Bool {
        return currentTotalQuantity >= 6
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order").font(.largeTitle).bold()

                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            FormTextField(placeholder: "Name", text: $name)
                            FormTextField(placeholder: "Phone", text: $phone)
                                .keyboardType(.phonePad)
                        }

                        FormTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)

                        VStack(alignment: .leading) {
                           Text("Address")
                               .font(.subheadline)
                               .foregroundColor(.gray)
                           TextEditor(text: $address)
                               .frame(height: 60)
                               .padding(8)
                               .background(Color.white)
                               .cornerRadius(8)
                               .overlay(
                                   RoundedRectangle(cornerRadius: 8)
                                       .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                               )
                       }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(spacing: 6) {
                            Text("Flavors (Min of 6):")
                                .font(.headline)
                            FlavorInputRow(flavor: OrderConstants.chocolateChip, quantity: $chocolateChipQuantity)
                            FlavorInputRow(flavor: OrderConstants.sprinkle, quantity: $sprinkleQuantity)
                            FlavorInputRow(flavor: OrderConstants.smore, quantity: $smoreQuantity)
                            FlavorInputRow(flavor: OrderConstants.oreo, quantity: $oreoQuantity)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }

                    Divider().padding(.vertical, 4)

                    let gridColumns: [GridItem] = [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .trailing)
                    ]

                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 10) {
                        // Promised By Label
                        Text("Promised By Date:")
                            .font(.headline)


                        // Delivery Toggle
                        Toggle(isOn: $isDelivery) {
                            Text("Delivery:")
                                .font(.headline)
                        }
                        .toggleStyle(SwitchToggleStyle())
                        
                        // Date Picker
                        DatePicker("", selection: $promisedDate, in: Date()..., displayedComponents: .date) // Prevents past dates
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    
                    Divider().padding(.vertical, 5)

                    HStack {
                        Text("Total Cost:")
                            .font(.headline)
                        Spacer()
                        Text("$\(String(format: "%.2f", totalCost))")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }

                    if isDelivery {
                        Text("Includes $6 delivery fee")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Divider().padding(.vertical, 6)

                    if showValidationError {
                        Text("Error: Please fill all required fields and ensure at least 6 cookies are ordered.")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }

                    if showSuccessMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(isNewCustomer ? "Order & Customer Created" : "Order Created")
                                .foregroundColor(.green)
                                .font(.headline)
                        }
                        .transition(.opacity)
                    }

                    Button(action: saveOrder) {
                        Text("Add Order")
                            .frame(maxWidth: .infinity, minHeight: 20)
                            .padding()
                            .background(isValidOrder ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isValidOrder)
                    .padding(.bottom, 18)

                    Spacer()
                }
                .padding()
                .padding(.bottom, keyboardOffset) // Adjusts based on keyboard height
                .onAppear { observeKeyboard() } // Detect keyboard
            }
        }
    }

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardOffset = keyboardSize.height * 0.4 // Moves screen up
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardOffset = 0
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber } // Extract only digits
        guard digits.count == 10 else { return number } // Ensure it's a 10-digit number

        let areaCode = digits.prefix(3)
        let middle = digits.dropFirst(3).prefix(3)
        let last = digits.dropFirst(6)

        return "\(areaCode)-\(middle)-\(last)"
    }

    private func saveOrder() {
        let newTotal = chocolateChipQuantity + sprinkleQuantity + smoreQuantity + oreoQuantity

        // Ensure the order meets the 6-cookie minimum
        guard newTotal >= 6 else {
            showValidationError = true
            return
        }

        // Check if customer already exists
        if let existingCustomer = CustomerEntity.isExistingCustomer(name: name, phone: phone, context: viewContext) {
            addOrder(to: existingCustomer)
        } else {
            createNewCustomer()
        }

        do {
            try viewContext.save()
            showSuccessMessage = true
            showValidationError = false
            resetFields()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSuccessMessage = false
            }
        } catch {
            print("Error saving order: \(error.localizedDescription)")
        }
    }
    
    private func addOrder(to customer: CustomerEntity) {
        let newOrder = OrderEntity(context: viewContext)
        newOrder.customer = customer
        newOrder.promisedDate = promisedDate
        newOrder.delivery = isDelivery
        addCookies (to: newOrder)
    }

    private func addCookies(to order: OrderEntity) {
        
        for (flavor, quantity) in cookieSelections {
            let newCookie = CookieEntity(context: viewContext)
            newCookie.flavor = flavor
            newCookie.quantity = quantity
            newCookie.totalCost = quantity * 2.5
            newCookie.order = order
        }
    }

    private func createNewCustomer() {
        let newCustomer = CustomerEntity(context: viewContext)
        newCustomer.id = UUID()
        newCustomer.name = name
        newCustomer.phone = phone
        newCustomer.email = email
        newCustomer.address = address
        newCustomer.totalCost = totalCost

        addOrder(to: newCustomer)
    }

    private func resetFields() {
        name = ""
        phone = ""
        email = ""
        address = ""
        chocolateChipQuantity = 0.0
        sprinkleQuantity = 0.0
        smoreQuantity = 0.0
        oreoQuantity = 0.0
        promisedDate = Date()
        isNewCustomer = true
        isDelivery = false
    }
}

struct FormTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
    }
}

struct FlavorInputRow: View {
    let flavor: String
    @Binding var quantity: Double

    var body: some View {
        HStack {
            Text(flavor)
                .font(.headline)

            Spacer()

            HStack(spacing: 6) {
                // Decrement Button
                Button(action: {
                    if quantity > 0 {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            quantity -= 1
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(quantity > 0 ? .blue : .gray)
                }
                .disabled(quantity == 0)

                Text("\(Int(quantity))")
                    .frame(width: 32)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                // Increment Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.10)) {
                        quantity += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 4)
    }
}














