//
//  Models.swift
//  CookieTracker
//
//  Created by Zachary Goldberg on 1/26/25.
//
import Foundation

struct Customer: Identifiable {
    let id: UUID
    let name: String
    let phone: String
    let email: String
    let address: String
    let orders: [Order]
    let delivery: Bool

    static func createCustomer(name: String, phone: String, email: String, address: String, orders: [Order], delivery: Bool) -> Customer {
        return Customer(
            id: UUID(),
            name: name,
            phone: phone,
            email: email,
            address: address,
            orders: orders,
            delivery: delivery
        )
    }
}

struct Order {
    let flavor: String
    let quantity: Int
}

