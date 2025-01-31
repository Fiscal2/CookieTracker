//
//  Models.swift
//  CookieTracker
//
//
//
//import Foundation
//import CoreData
//
//// MARK: - Customer Entity (Core Data)
//@objc(Customer)
//public class Customer: NSManagedObject {
//    @NSManaged public var id: UUID
//    @NSManaged public var name: String
//    @NSManaged public var phone: String
//    @NSManaged public var email: String
//    @NSManaged public var address: String?
//    @NSManaged public var delivery: Bool
//    @NSManaged public var orders: NSSet?
//}
//
//// MARK: - Order Entity (Core Data)
//@objc(Order)
//public class Order: NSManagedObject {
//    @NSManaged public var flavor: String
//    @NSManaged public var quantity: Int16
//    @NSManaged public var customer: Customer?
//}
//
//// MARK: - Core Data Helpers (Convenience Initializers)
//extension Customer {
//    static func createCustomer(name: String, phone: String, email: String, address: String?, delivery: Bool, orders: [Order], context: NSManagedObjectContext) -> Customer {
//        let newCustomer = Customer(context: context)
//        newCustomer.id = UUID()
//        newCustomer.name = name
//        newCustomer.phone = phone
//        newCustomer.email = email
//        newCustomer.address = address
//        newCustomer.delivery = delivery
//        newCustomer.orders = NSSet(array: orders)
//        return newCustomer
//    }
//}
//
//extension Order {
//    static func createOrder(flavor: String, quantity: Int16, customer: Customer, context: NSManagedObjectContext) -> Order {
//        let newOrder = Order(context: context)
//        newOrder.flavor = flavor
//        newOrder.quantity = quantity
//        newOrder.customer = customer
//        return newOrder
//    }
//}

