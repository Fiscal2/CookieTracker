//
//  customerExtension.swift
//  CookieTracker
//
import CoreData

extension CustomerEntity {
    /// Checks if a customer already exists in Core Data based on name and phone number.
    static func isExistingCustomer(name: String, phone: String, context: NSManagedObjectContext) -> CustomerEntity? {
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND phone == %@", name, phone)

        do {
            let customers = try context.fetch(fetchRequest)
            return customers.first // Return existing customer if found
        } catch {
            print("Error fetching customer: \(error.localizedDescription)")
            return nil
        }
    }
}

