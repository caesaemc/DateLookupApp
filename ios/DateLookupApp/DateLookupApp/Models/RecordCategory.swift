import SwiftUI

enum RecordCategory: String, CaseIterable, Codable, Identifiable {
    case activity
    case meal
    case expense
    case tip

    var id: String { rawValue }

    var title: String {
        switch self {
        case .activity: return "运动"
        case .meal: return "饮食"
        case .expense: return "记账"
        case .tip: return "Tips"
        }
    }

    var symbolName: String {
        switch self {
        case .activity: return "figure.run"
        case .meal: return "fork.knife"
        case .expense: return "yensign.circle"
        case .tip: return "lightbulb"
        }
    }

    var tint: Color {
        switch self {
        case .activity: return .appGreen
        case .meal: return .appOrange
        case .expense: return .appBlue
        case .tip: return .appRose
        }
    }
}

