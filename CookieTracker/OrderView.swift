//
//  OrderView.swift
//  CookieTracker
//
//  Created by Zachary Goldberg on 1/26/25.
//
import SwiftUI

struct OrderView: View {
    @Binding var customers: [Customer]
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var chocolateChipQuantity = 0
    @State private var sprinkleQuantity = 0
    @State private var smoreQuantity = 0
    @State private var isNewCustomer = true // Tracks whether the customer is new
    @State private var showSuccessMessage = false
    @State private var showValidationError = false

    var isDelivery: Bool {
        !address.trimmingCharacters(in: .whitespaces).isEmpty // Delivery is true if address is provided
    }

    var totalCost: Int {
        let totalCookies = chocolateChipQuantity + sprinkleQuantity + smoreQuantity
        let cookieCost = (totalCookies / 12) * 30 + (totalCookies % 12 > 0 ? 15 : 0) // $30 per dozen, $15 for half-dozen
        let deliveryFee = isDelivery ? 6 : 0
        return cookieCost + deliveryFee
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order").font(.largeTitle).bold()

            // Customer Information Inputs
            VStack(alignment: .leading, spacing: 16) {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Phone", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Address", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // New Customer Option
            VStack(alignment: .leading, spacing: 8) {
                Text("New Customer?")
                    .font(.subheadline)
                    .bold()

                HStack(spacing: 8) {
                    Button(action: {
                        isNewCustomer = true
                    }) {
                        Text("Yes")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .background(isNewCustomer ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }

                    Button(action: {
                        isNewCustomer = false
                    }) {
                        Text("No")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .background(!isNewCustomer ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
            }

            Divider()
                .padding(.vertical, 8)

            // Cookie Flavors and Quantities
            VStack(alignment: .leading, spacing: 10) {
                Text("Choose Flavors (Minimum of 6):")
                    .font(.headline)

                FlavorInputRow(flavor: "Chocolate Chip", quantity: $chocolateChipQuantity)
                FlavorInputRow(flavor: "Sprinkle", quantity: $sprinkleQuantity)
                FlavorInputRow(flavor: "S'more", quantity: $smoreQuantity)
            }

            Divider()
                .padding(.vertical, 8)

            // Total Cost
            HStack {
                Text("Total Cost:")
                    .font(.headline)
                Spacer()
                Text("$\(totalCost)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            if isDelivery {
                Text("Includes $6 delivery fee")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Divider()
                .padding(.vertical, 8)

            // Validation Error Message
            if showValidationError {
                Text("Error: Total quantity must be 6 or divisible by 12.")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            // Success Message
            if showSuccessMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Customer Created")
                        .foregroundColor(.green)
                        .font(.headline)
                }
                .transition(.opacity)
            }

            // Add Customer & Order Button
            Button(action: {
                if isValidOrder() {
                    let orders = [
                        Order(flavor: "Chocolate Chip", quantity: chocolateChipQuantity),
                        Order(flavor: "Sprinkle", quantity: sprinkleQuantity),
                        Order(flavor: "S'more", quantity: smoreQuantity)
                    ]

                    // Create a new customer
                    let newCustomer = Customer.createCustomer(
                        name: name,
                        phone: phone,
                        email: email,
                        address: address,
                        orders: orders,
                        delivery: isDelivery
                    )

                    // Append the customer to the local list
                    customers.append(newCustomer)
                    print("Customer added: \(newCustomer.name)")

                    // Show success message
                    showSuccessMessage = true
                    showValidationError = false // Clear any error messages

                    // Hide success message after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessMessage = false
                    }

                    resetFields() // Clear the input fields
                } else {
                    showValidationError = true // Show validation error
                }
            }) {
                Text("Add Customer & Order")
                    .frame(maxWidth: .infinity, minHeight: 20)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom, 20)

            Spacer()
        }
        .padding()
    }

    // Helper method to reset input fields
    private func resetFields() {
        name = ""
        phone = ""
        email = ""
        address = ""
        chocolateChipQuantity = 0
        sprinkleQuantity = 0
        smoreQuantity = 0
        isNewCustomer = true // Reset to new customer
    }

    // Validate the order
    private func isValidOrder() -> Bool {
        let quantities = [chocolateChipQuantity, sprinkleQuantity, smoreQuantity]
        let total = quantities.reduce(0, +) // Sum up all quantities

        // Allow total quantities of 6 or divisible by 12
        return total == 6 || total % 12 == 0
    }
}






struct FlavorInputRow: View {
    let flavor: String
    @Binding var quantity: Int

    var body: some View {
        HStack {
            Text(flavor)
                .font(.headline)
            Spacer()
            HStack(spacing: 10) {
                // Decrement Button
                Button(action: {
                    if quantity > 0 { quantity -= 1 } // Decrease by 1
                }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(quantity > 0 ? .blue : .gray) // Disable if at 0
                }

                // Quantity Display
                Text("\(quantity)")
                    .frame(width: 40, alignment: .center)
                    .font(.headline)

                // Increment Button
                Button(action: {
                    quantity += 1 // Increase by 1
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}












