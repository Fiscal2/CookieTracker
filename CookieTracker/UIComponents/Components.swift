import SwiftUICore
import SwiftUI

struct FormTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
    }
}

struct FlavorInputRow: View {
    let flavor: String
    @Binding var quantity: Double
    
    @State private var isLongPressing = false
    
    var body: some View {
        HStack {
            Text(flavor)
                .font(.headline)

            Spacer()

            HStack(spacing: 6) {
                // Decrement Button
                Button(action: {
                    if quantity > 0 {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            quantity -= 1
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(quantity > 0 ? .blue : .gray)
                }
                .disabled(quantity == 0)

                Text("\(Int(quantity))")
                    .frame(width: 32)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                // Increment Button
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .simultaneousGesture(TapGesture()
                    .onEnded {
                        if !isLongPressing {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                quantity += 1
                            }
                        }
                    }
                )
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                    .onChanged { _ in
                        isLongPressing = true
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            quantity += 6
                        }
                        isLongPressing = false
                    }
                )
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 4)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Text(value)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // Show banner and sound when app is open
    }
}

