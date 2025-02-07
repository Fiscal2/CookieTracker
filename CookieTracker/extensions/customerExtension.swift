import CoreData
import UserNotifications

extension CustomerEntity {
    static func isExistingCustomer(name: String, phone: String, context: NSManagedObjectContext) -> CustomerEntity? {
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND phone == %@", name, phone)

        do {
            let customers = try context.fetch(fetchRequest)
            return customers.first // Return first customer that matches the fetch request
        } catch {
            print("Error fetching customer: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createNewOrder(promisedDate: Date, isDelivery: Bool, cookieSelections: [String: Double], context: NSManagedObjectContext) {
        let newOrder = OrderEntity(context: context)
        newOrder.promisedDate = promisedDate
        newOrder.delivery = isDelivery
        newOrder.customer = self
        newOrder.isCompleted = false
        newOrder.addCookies(from: cookieSelections, to: context)
        newOrder.scheduleNotification(customerName: name ?? "")
        
    }
    
    func deleteOrder(order: OrderEntity, context: NSManagedObjectContext) {
        if let orders = self.orders as? Set<OrderEntity>, orders.contains(order) {
            self.removeFromOrders(order)
        }

        context.delete(order)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(order.objectID)"])

        do {
            try context.save()
        } catch {
            print("Error after deleting order: \(error.localizedDescription)")
        }
    }
}
