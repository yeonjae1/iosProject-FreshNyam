import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "시스템 기본"
    case light = "라이트 모드"
    case dark = "다크 모드"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
