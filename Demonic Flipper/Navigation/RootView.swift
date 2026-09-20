//
//  RootView.swift
//  Demonic Flipper
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var highScoreStore = HighScoreStore()

    var body: some View {
        Group {
            switch router.route {
            case .menu:
                MainMenuView()
            case .game:
                PinballGameView()
            case .highScores:
                HighScoreView()
            case .settings:
                SettingsView()
            }
        }
        .environmentObject(router)
        .environmentObject(highScoreStore)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
}
