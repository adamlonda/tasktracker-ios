import Models
import SwiftUI

extension Priority {
    var imageName: String {
        switch self {
        case .normal:
            return "minus"
        case .low:
            return "chevron.down"
        case .high:
            return "chevron.up"
        }
    }

    var color: Color {
        switch self {
        case .normal:
            return .gray
        case .low:
            return .blue
        case .high:
            return .red
        }
    }

    var name: String {
        rawValue.capitalized
    }
}
