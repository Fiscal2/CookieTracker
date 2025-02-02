//
//  orderExtension.swift
//  CookieTracker
//
extension OrderEntity{
    func TotalOrderCost() -> Double {
        let cookiesArray = Array(cookies as? Set<CookieEntity> ?? [])
        let totalCookiesForOrder = cookiesArray.reduce(0) { $0 + $1.quantity}
        return totalCookiesForOrder
    }
    
    func TotalCookiesInOrder() -> Int {
        let cookiesArray = Array(cookies as? Set<CookieEntity> ?? [])
        return Int(cookiesArray.reduce(0) { $0 + $1.quantity})
    }
}

extension [OrderEntity]{
    func TotalOrdersCost() -> Double {
        return self.reduce(0) {$0 + $1.TotalOrderCost()}
    }
}
