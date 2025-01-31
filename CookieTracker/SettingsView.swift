//
//  SettingsView.swift
//  CookieTracker
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false  // Stores user preference

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)  // Dark mode toggle
                }
            }
            .navigationTitle("Settings")
        }
    }
}


