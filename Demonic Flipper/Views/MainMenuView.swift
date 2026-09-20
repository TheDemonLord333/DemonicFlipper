//
//  MainMenuView.swift
//  Demonic Flipper
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var highScoreStore: HighScoreStore
    @State private var titleGlow = false

    var body: some View {
        ZStack {
            DemonicBackground()

            VStack(spacing: 28) {
                Spacer(minLength: 40)

                VStack(spacing: 6) {
                    Text("DEMONIC")
                        .font(DemonicFont.title(size: 44))
                        .foregroundStyle(DemonicPalette.steelSilver)
                        .tracking(6)
                    Text("FLIPPER")
                        .font(DemonicFont.title(size: 56))
                        .foregroundStyle(DemonicPalette.neonRed)
                        .tracking(4)
                        .shadow(color: DemonicPalette.neonRed.opacity(titleGlow ? 0.9 : 0.4), radius: titleGlow ? 22 : 8)
                }
                .multilineTextAlignment(.center)

                Text("Highscore: \(highScoreStore.bestScore)")
                    .font(DemonicFont.heading(size: 18))
                    .foregroundStyle(DemonicPalette.emberOrange)

                Spacer()

                VStack(spacing: 18) {
                    MenuButton(title: "Spielen", systemImage: "flame.fill") {
                        router.route = .game
                    }
                    MenuButton(title: "Highscores", systemImage: "crown.fill") {
                        router.route = .highScores
                    }
                    MenuButton(title: "Einstellungen", systemImage: "gearshape.fill") {
                        router.route = .settings
                    }
                }
                .padding(.horizontal, 36)

                Spacer(minLength: 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                titleGlow = true
            }
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppRouter())
        .environmentObject(HighScoreStore())
}
