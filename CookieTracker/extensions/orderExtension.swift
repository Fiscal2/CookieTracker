import CoreData

extension OrderEntity{
    func TotalOrderCost() -> Double {
        let cookiesArray = Array(cookies as? Set<CookieEntity> ?? [])
        let totalCookiesForOrder = cookiesArray.reduce(0) { $0 + $1.quantity}
        return (totalCookiesForOrder * 2.5) + (delivery ? 6.0 : 0)
    }
    
    func TotalCookiesInOrder() -> Int {
        let cookiesArray = Array(cookies as? Set<CookieEntity> ?? [])
        return Int(cookiesArray.reduce(0) { $0 + $1.quantity})
    }
    
    func addCookies(from cookieSelections: [String: Double], to context: NSManagedObjectContext) {
        for (flavor, quantity) in cookieSelections {
            let newCookie = CookieEntity(context: context)
            newCookie.flavor = flavor
            newCookie.quantity = quantity
            newCookie.totalCost = Double(quantity) * 2.5
            newCookie.order = self
        }
    }
}

extension [OrderEntity]{
    func TotalOrdersCost() -> Double {
        return self.reduce(0) {$0 + $1.TotalOrderCost()}
    }
}
