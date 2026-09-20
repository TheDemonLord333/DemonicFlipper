//
//  GameOverView.swift
//  Demonic Flipper
//

import SwiftUI

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let onReplay: () -> Void
    let onMainMenu: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("DEINE SEELE IST GEFALLEN")
                    .font(DemonicFont.title(size: 24))
                    .foregroundStyle(DemonicPalette.neonRed)
                    .multilineTextAlignment(.center)
                    .shadow(color: DemonicPalette.neonRed, radius: 12)

                VStack(spacing: 6) {
                    Text("Punkte: \(score)")
                        .font(DemonicFont.heading(size: 20))
                    Text("Highscore: \(max(score, highScore))")
                        .font(DemonicFont.body())
                        .foregroundStyle(DemonicPalette.emberOrange)
                }
                .foregroundStyle(DemonicPalette.steelSilver)

                VStack(spacing: 14) {
                    MenuButton(title: "Erneut spielen", systemImage: "arrow.clockwise", action: onReplay)
                    MenuButton(title: "Hauptmenü", systemImage: "house.fill", action: onMainMenu)
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DemonicPalette.charcoal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DemonicPalette.bloodRed, lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 32)
        }
    }
}
