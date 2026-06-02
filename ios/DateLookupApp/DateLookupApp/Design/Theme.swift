import SwiftUI

extension Color {
    static let appBackground = Color(red: 0.965, green: 0.988, blue: 0.992)
    static let appSurface = Color.white
    static let appSurfaceSoft = Color(red: 0.91, green: 0.98, blue: 0.97)
    static let appText = Color(red: 0.08, green: 0.13, blue: 0.18)
    static let appMuted = Color(red: 0.39, green: 0.45, blue: 0.52)
    static let appBorder = Color(red: 0.86, green: 0.91, blue: 0.93)
    static let appTeal = Color(red: 0.125, green: 0.71, blue: 0.66)
    static let appGreen = Color(red: 0.20, green: 0.73, blue: 0.52)
    static let appOrange = Color(red: 0.96, green: 0.62, blue: 0.24)
    static let appBlue = Color(red: 0.44, green: 0.62, blue: 0.96)
    static let appRose = Color(red: 0.95, green: 0.43, blue: 0.56)
}

struct PanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 18, y: 10)
    }
}

extension View {
    func panelStyle() -> some View {
        modifier(PanelModifier())
    }
}

