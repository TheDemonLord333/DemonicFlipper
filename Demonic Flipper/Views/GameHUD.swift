//
//  GameHUD.swift
//  Demonic Flipper
//

import SwiftUI

/// Top status bar during play: score, Demonic Multiplier, Hell Combo,
/// remaining balls, glowing TILT warning, and the pause button.
struct GameHUD: View {
    @ObservedObject var gameState: GameState
    let onPause: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SEELE: \(gameState.score)")
                    .font(DemonicFont.heading(size: 20))
                    .foregroundStyle(DemonicPalette.steelSilver)

                HStack(spacing: 10) {
                    Label("x\(gameState.multiplier)", systemImage: "flame.fill")
                        .foregroundStyle(DemonicPalette.emberOrange)
                    if gameState.comboActive {
                        Text("HELL COMBO x\(gameState.comboCount)")
                            .foregroundStyle(DemonicPalette.neonRed)
                            .transition(.opacity)
                    }
                }
                .font(DemonicFont.body(size: 13))
                .animation(.easeInOut(duration: 0.2), value: gameState.comboActive)

                HStack(spacing: 4) {
                    ForEach(0..<max(gameState.ballsRemaining, 0), id: \.self) { _ in
                        Circle()
                            .fill(DemonicPalette.steelSilver)
                            .frame(width: 8, height: 8)
                    }
                }
            }

            Spacer()

            if gameState.isTilted {
                Text("TILT")
                    .font(DemonicFont.title(size: 26))
                    .foregroundStyle(DemonicPalette.neonRed)
                    .shadow(color: DemonicPalette.neonRed, radius: 12)
            }

            Spacer()

            Button(action: onPause) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(DemonicPalette.steelSilver)
            }
        }
        .padding(.horizontal, 20)
    }
}
