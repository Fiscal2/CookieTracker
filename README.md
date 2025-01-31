🍪 CookieTracker

A SwiftUI & Core Data-powered app for tracking customer orders and managing an order list.

📌 Features

✅ Add & Manage Customers: Save customer details, including name, phone, email, and address.
✅ Track Orders: Store multiple orders per customer with different flavors and quantities.
✅ Pricing Calculation: Automatically calculates total cost based on cookie prices and delivery fees.
✅ Search Functionality: Easily search for customers in the customer list.
✅ Core Data Persistence: Customer and order data are stored locally using Core Data.

🎯 Core Functionalities

1️⃣ Add a Customer & Order

    Enter customer details (name, phone, email, address).
    Select cookie flavors and quantities.
    Delivery fee automatically applies if an address is entered.
    Order is saved locally using Core Data.

2️⃣ View & Search Customers

    Search by name in the Customer ListView.
    Click on a customer to view details.

3️⃣ View Order Details

    View total cost based on $2.50 per cookie pricing model.
    Delivery fee is displayed if applicable.

4️⃣ Delete a Customer (with Confirmation)

    Swipe left to delete a customer.
    A confirmation alert appears before deletion.

🛠️ Tech Stack

    SwiftUI → Modern UI framework for iOS
    Core Data → Local data storage for customers and orders
    NSPersistentContainer → Handles Core Data stack
    @FetchRequest & @Environment → Core Data integration in SwiftUI
    MVVM Architecture → Clean separation of concerns
    
⚡ Future Improvements

🔹 Show multiple orders for same customer in Customer Detail View page.
🔹 Add deliver by/pick up date and reminders sent through notification center.
🔹 Data Export (Export customer order history as a CSV or PDF).
🔹 Cloud Sync (Use CloudKit to sync orders across devices).
🔹 Revenue/Income tracking.


📜 License

This project is licensed under the MIT License.
