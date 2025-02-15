import CoreData
import UserNotifications

extension OrderEntity{
    func TotalOrderCost() -> Double {
        let cookiesArray = Array(cookies as? Set<CookieEntity> ?? [])
        let totalCookiesForOrder = cookiesArray.reduce(0) { $0 + $1.quantity}
        return (totalCookiesForOrder * OrderConstants.cookiePrice) + (delivery ? OrderConstants.deliveryFee : 0)
    }
    
    func TotalCookiesInOrder() -> Int {
        let cookiesArray = Array(cookies as? Set<CookieEntity> ?? [])
        return Int(cookiesArray.reduce(0) { $0 + $1.quantity})
    }
    
    func addCookies(from cookieSelections: [String: Double], to context: NSManagedObjectContext) {
        for (flavor, quantity) in cookieSelections where quantity > 0 {
            let newCookie = CookieEntity(context: context)
            newCookie.flavor = flavor
            newCookie.quantity = quantity
            newCookie.totalCost = Double(quantity) * OrderConstants.cookiePrice
            newCookie.order = self
        }
    }
    
    func scheduleNotification(customerName: String) {
        guard let promisedDate = promisedDate else { return }
        // display notification 1 hour before order is due
        let adjustedPromisedDate = promisedDate.addingTimeInterval(-3600)
        
        let content = UNMutableNotificationContent()
        content.title = "Order Reminder"
        content.body = "\(customerName)'s order of \(TotalCookiesInOrder()) cookies is scheduled for \(delivery ? "delivery" : "pickup") at \(promisedDate.formattedDateTime())."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: adjustedPromisedDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(objectID)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(promisedDate.formattedDateTime()).")
            }
        }
    }
}

extension [OrderEntity]{
    func TotalOrdersCost() -> Double {
        return self.reduce(0) { $0 + $1.TotalOrderCost() }
    }
    
    func historicalOrders() -> [OrderEntity] {
        return self.filter { $0.isCompleted == true }
    }
    
    func inProgressOrders() -> [OrderEntity] {
        return self.filter { $0.isCompleted == false }
    }
}
