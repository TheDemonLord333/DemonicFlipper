//
//  DemonicFont.swift
//  Demonic Flipper
//

import SwiftUI
import UIKit

/// Safe font access: falls back to a system font whenever a custom
/// font name is unavailable, so a missing font can never crash the app.
enum DemonicFont {
    private static let titleCandidates = ["AvenirNext-Heavy", "HelveticaNeue-CondensedBlack"]

    static func title(size: CGFloat) -> Font {
        for name in titleCandidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: .black, design: .serif)
    }

    static func heading(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func body(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
}
