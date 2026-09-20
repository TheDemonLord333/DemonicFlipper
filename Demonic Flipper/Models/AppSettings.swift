//
//  AppSettings.swift
//  Demonic Flipper
//

import Foundation

/// Central place for settings keys so SwiftUI's `@AppStorage` and
/// plain `UserDefaults` reads (e.g. from SpriteKit code) always agree.
enum AppSettings {
    static let soundEnabledKey = "demonicFlipper.soundEnabled"
    static let hapticsEnabledKey = "demonicFlipper.hapticsEnabled"

    static var hapticsEnabled: Bool {
        (UserDefaults.standard.object(forKey: hapticsEnabledKey) as? Bool) ?? true
    }

    static var soundEnabled: Bool {
        (UserDefaults.standard.object(forKey: soundEnabledKey) as? Bool) ?? true
    }
}
