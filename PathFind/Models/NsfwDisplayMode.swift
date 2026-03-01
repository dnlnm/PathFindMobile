import SwiftUI

enum NsfwDisplayMode: String, CaseIterable {
  case blur
  case hide
  case show

  var label: String {
    switch self {
    case .blur: return "Blur Content"
    case .hide: return "Hide from List"
    case .show: return "Show Content"
    }
  }

  var icon: String {
    switch self {
    case .blur: return "eye.slash"
    case .hide: return "eye.slash.fill"
    case .show: return "eye"
    }
  }
}
