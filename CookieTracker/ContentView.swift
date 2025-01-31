//
//  ContentView.swift
//  CookieTracker
//
// 
//
import SwiftUI

struct ContentView: View {
    let viewContext = CoreDataStack.shared.persistentContainer.viewContext

    var body: some View {
        TabView {
            CustomerListView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Customers")
                }
                .environment(\.managedObjectContext, viewContext)

            OrderView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Orders")
                }
                .environment(\.managedObjectContext, viewContext)

            Text("Settings")
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}


