import Foundation

extension Formatter {
    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = Locale.current.groupingSeparator
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        Formatter.number.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
