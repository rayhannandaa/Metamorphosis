import SwiftUI

extension Color {
    init(hex: String) {
        let hexString = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let alpha: UInt64
        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch hexString.count {
        case 3:
            alpha = 255
            red = (rgb >> 8) * 17
            green = (rgb >> 4 & 0xF) * 17
            blue = (rgb & 0xF) * 17
        case 6:
            alpha = 255
            red = rgb >> 16
            green = rgb >> 8 & 0xFF
            blue = rgb & 0xFF
        case 8:
            alpha = rgb >> 24
            red = rgb >> 16 & 0xFF
            green = rgb >> 8 & 0xFF
            blue = rgb & 0xFF
        default:
            alpha = 255
            red = 0
            green = 0
            blue = 0
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
