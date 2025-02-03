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
                        .frame(width: 24, height: 24)
                        .foregroundColor(quantity > 0 ? .blue : .gray)
                }
                .disabled(quantity == 0)

                Text("\(Int(quantity))")
                    .frame(width: 32)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                // Increment Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.10)) {
                        quantity += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
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
