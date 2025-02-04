import SwiftUI
import CoreData

struct CustomerListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: CustomerEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomerEntity.name, ascending: true)]
    ) private var customers: FetchedResults<CustomerEntity>

    @State private var searchText = ""
    @State private var showDeleteConfirmation = false // Track if alert should be shown
    @State private var customerToDelete: CustomerEntity? // Store the customer to delete

    var filteredCustomers: [CustomerEntity] {
        customers.filter { searchText.isEmpty || ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false) }
    }

    var body: some View {
        NavigationView {
            List {
                if filteredCustomers.isEmpty {
                    Text("No customers yet. Add them in the Orders section.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ForEach(filteredCustomers) { customer in
                        NavigationLink(destination: CustomerDetailView(customer: customer)) {
                            HStack {
                                Text(customer.name ?? "Unknown")
                                Spacer()
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: confirmDeleteCustomer) // Trigger confirmation alert
                }
            }
            .navigationTitle("Customers")
            .searchable(text: $searchText, prompt: "Search customers") // Built-in search bar
            .alert("Delete?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {} // Cancel deletion
                Button("Delete", role: .destructive) { deleteConfirmedCustomer() } // Confirm deletion
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func confirmDeleteCustomer(at offsets: IndexSet) {
        if let index = offsets.first {
            customerToDelete = customers[index]
            showDeleteConfirmation = true // Show alert
        }
    }

    private func deleteConfirmedCustomer() {
        if let customerToDelete {
            viewContext.delete(customerToDelete) // Delete the customer

            do {
                try viewContext.save()
            } catch {
                print("Error deleting customer: \(error.localizedDescription)")
            }

            self.customerToDelete = nil // Reset state
        }
    }
}
