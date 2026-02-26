import SwiftUI

extension Color {
  // MARK: - Brand Colors
  static let pfAccent = Color(red: 0.4, green: 0.55, blue: 1.0)  // Soft blue accent
  static let pfAccentLight = Color(red: 0.55, green: 0.7, blue: 1.0)
  static let pfBackground = Color(red: 0.07, green: 0.07, blue: 0.09)  // Near-black bg
  static let pfSurface = Color(red: 0.11, green: 0.11, blue: 0.14)  // Card surfaces
  static let pfSurfaceLight = Color(red: 0.15, green: 0.15, blue: 0.19)  // Elevated surface
  static let pfBorder = Color(white: 0.2)
  static let pfTextPrimary = Color(white: 0.95)
  static let pfTextSecondary = Color(white: 0.6)
  static let pfTextTertiary = Color(white: 0.4)
  static let pfDestructive = Color(red: 0.95, green: 0.3, blue: 0.3)
  static let pfSuccess = Color(red: 0.3, green: 0.85, blue: 0.5)
  static let pfWarning = Color(red: 1.0, green: 0.75, blue: 0.3)

  // MARK: - Tag Colors
  static let tagColors: [Color] = [
    Color(red: 0.4, green: 0.55, blue: 1.0),
    Color(red: 0.55, green: 0.4, blue: 1.0),
    Color(red: 1.0, green: 0.5, blue: 0.5),
    Color(red: 0.3, green: 0.8, blue: 0.6),
    Color(red: 1.0, green: 0.7, blue: 0.3),
    Color(red: 0.9, green: 0.4, blue: 0.7),
    Color(red: 0.3, green: 0.75, blue: 0.9),
  ]

  static func tagColor(for name: String) -> Color {
    let hash = abs(name.hashValue)
    return tagColors[hash % tagColors.count]
  }

  // MARK: - From Hex String
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    guard hexSanitized.count == 6 else { return nil }

    var rgb: UInt64 = 0
    Scanner(string: hexSanitized).scanHexInt64(&rgb)

    self.init(
      red: Double((rgb & 0xFF0000) >> 16) / 255.0,
      green: Double((rgb & 0x00FF00) >> 8) / 255.0,
      blue: Double(rgb & 0x0000FF) / 255.0
    )
  }
}
