//
//  CookieTrackerApp.swift
//  CookieTracker
//
import SwiftUI

@main
struct CookieTrackerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    init() {
        applyTheme()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    applyTheme()
                }
        }
    }

    private func applyTheme() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
}

