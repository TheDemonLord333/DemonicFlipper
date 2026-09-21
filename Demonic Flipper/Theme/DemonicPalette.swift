//
//  DemonicPalette.swift
//  Demonic Flipper
//

import SwiftUI
import UIKit

enum DemonicPalette {
    // MARK: - Raw UIKit colors (used directly inside SpriteKit)
    static let uiAbyssBlack = UIColor(red: 0.04, green: 0.03, blue: 0.05, alpha: 1)
    static let uiCharcoal = UIColor(red: 0.10, green: 0.09, blue: 0.11, alpha: 1)
    static let uiBloodRed = UIColor(red: 0.45, green: 0.02, blue: 0.05, alpha: 1)
    static let uiNeonRed = UIColor(red: 1.0, green: 0.12, blue: 0.16, alpha: 1)
    static let uiViolet = UIColor(red: 0.42, green: 0.08, blue: 0.62, alpha: 1)
    static let uiEmberOrange = UIColor(red: 1.0, green: 0.45, blue: 0.1, alpha: 1)
    static let uiSteelSilver = UIColor(red: 0.72, green: 0.74, blue: 0.78, alpha: 1)

    // MARK: - SwiftUI colors
    static let abyssBlack = Color(uiAbyssBlack)
    static let charcoal = Color(uiCharcoal)
    static let bloodRed = Color(uiBloodRed)
    static let neonRed = Color(uiNeonRed)
    static let violet = Color(uiViolet)
    static let emberOrange = Color(uiEmberOrange)
    static let steelSilver = Color(uiSteelSilver)

    // MARK: - Gradients
    static let backgroundGradient = LinearGradient(
        colors: [abyssBlack, charcoal, Color.black],
        startPoint: .top,
        endPoint: .bottom
    )

    static let gateGradient = RadialGradient(
        colors: [neonRed.opacity(0.9), violet.opacity(0.6), .clear],
        center: .center,
        startRadius: 4,
        endRadius: 220
    )
}
