//
//  HighScoreView.swift
//  Demonic Flipper
//

import SwiftUI

struct HighScoreView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var highScoreStore: HighScoreStore

    var body: some View {
        ZStack {
            DemonicBackground()

            VStack(spacing: 24) {
                Text("HIGHSCORES")
                    .font(DemonicFont.title(size: 32))
                    .foregroundStyle(DemonicPalette.neonRed)
                    .padding(.top, 40)

                if highScoreStore.topScores.isEmpty {
                    Spacer()
                    Text("Noch keine Seelen geopfert.")
                        .font(DemonicFont.body())
                        .foregroundStyle(DemonicPalette.steelSilver)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(highScoreStore.topScores.enumerated()), id: \.offset) { index, score in
                                HStack {
                                    Text("#\(index + 1)")
                                        .foregroundStyle(DemonicPalette.emberOrange)
                                    Spacer()
                                    Text("\(score)")
                                        .foregroundStyle(DemonicPalette.steelSilver)
                                }
                                .font(DemonicFont.heading(size: 18))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(DemonicPalette.charcoal.opacity(0.8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(DemonicPalette.bloodRed, lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    Spacer()
                }

                MenuButton(title: "Zurück", systemImage: "arrow.uturn.left") {
                    router.route = .menu
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    HighScoreView()
        .environmentObject(AppRouter())
        .environmentObject(HighScoreStore())
}
