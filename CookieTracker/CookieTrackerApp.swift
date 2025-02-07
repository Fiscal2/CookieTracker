import SwiftUI
import UserNotifications

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
                    requestNotificationPermission()
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
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            } else if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }
    }
}

