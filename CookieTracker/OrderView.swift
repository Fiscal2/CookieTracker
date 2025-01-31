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
    @State private var chocolateChipQuantity = 0
    @State private var sprinkleQuantity = 0
    @State private var smoreQuantity = 0
    @State private var isNewCustomer = true
    @State private var showSuccessMessage = false
    @State private var showValidationError = false

    var isDelivery: Bool {
        !address.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var totalCost: Double {
        let totalCookies = chocolateChipQuantity + sprinkleQuantity + smoreQuantity
        let cookieCost = Double(totalCookies) * 2.5
        let deliveryFee = isDelivery ? 6.0 : 0.0
        return cookieCost + deliveryFee
    }

    var isValidOrder: Bool {
        let totalCookies = chocolateChipQuantity + sprinkleQuantity + smoreQuantity
        return !name.isEmpty && !phone.isEmpty && !email.isEmpty && totalCookies >= 6
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order").font(.largeTitle).bold()

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

            Divider().padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Choose Flavors (Minimum of 6 Total):")
                    .font(.headline)

                FlavorInputRow(flavor: "Chocolate Chip", quantity: $chocolateChipQuantity)
                FlavorInputRow(flavor: "Sprinkle", quantity: $sprinkleQuantity)
                FlavorInputRow(flavor: "S'more", quantity: $smoreQuantity)
            }

            Divider().padding(.vertical, 8)

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

            Divider().padding(.vertical, 8)

            if showValidationError {
                Text("Error: Please fill all required fields and ensure at least 6 cookies are ordered.")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

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

            Button(action: saveOrder) {
                Text("Add Customer & Order")
                    .frame(maxWidth: .infinity, minHeight: 20)
                    .padding()
                    .background(isValidOrder ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!isValidOrder)
            .padding(.bottom, 20)

            Spacer()
        }
        .padding()
    }

    private func saveOrder() {
        if isValidOrder {
            let newCustomer = CustomerEntity(context: viewContext)
            newCustomer.id = UUID()
            newCustomer.name = name
            newCustomer.phone = phone
            newCustomer.email = email
            newCustomer.address = address
            newCustomer.delivery = isDelivery
            newCustomer.totalCost = totalCost

            let flavors = [
                ("Chocolate Chip", chocolateChipQuantity),
                ("Sprinkle", sprinkleQuantity),
                ("S'more", smoreQuantity)
            ]

            // Create a mutable set for the orders
            var orderSet = Set<OrderEntity>()

            for (flavor, quantity) in flavors where quantity > 0 {
                let newOrder = OrderEntity(context: viewContext)
                newOrder.flavor = flavor
                newOrder.quantity = Int16(quantity)
                newOrder.customer = newCustomer // Establish relationship

                orderSet.insert(newOrder) // Add order to set
            }

            // Assign orders to the customer (corrected)
            newCustomer.orders = NSSet(set: orderSet)

            do {
                try viewContext.save()
                showSuccessMessage = true
                showValidationError = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccessMessage = false
                }
            } catch {
                print("Error saving order: \(error.localizedDescription)")
            }
        } else {
            showValidationError = true
        }
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
                Button(action: { if quantity > 0 { quantity -= 1 } }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(quantity > 0 ? .blue : .gray)
                }
                Text("\(quantity)")
                    .frame(width: 40, alignment: .center)
                    .font(.headline)
                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}













