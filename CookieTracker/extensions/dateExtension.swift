import SwiftUI

// Date Formatter for displaying the "Promised By" date
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    func formattedDateTime(_ date: Date) -> String {
       let formatter = DateFormatter()
       formatter.dateStyle = .medium
       formatter.timeStyle = .short
       return formatter.string(from: date)
   }
}
