//
//  SettingsView.swift
//  CookieTracker
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) {
                            updateAppearance()
                        }
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            updateAppearance()
        }
    }

    private func updateAppearance() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}




