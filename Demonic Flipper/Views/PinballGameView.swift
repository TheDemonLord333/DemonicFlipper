//
//  PinballGameView.swift
//  Demonic Flipper
//

import SwiftUI
import SpriteKit

struct PinballGameView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var highScoreStore: HighScoreStore
    @StateObject private var gameState = GameState()
    @State private var scene: DemonicFlipperScene = {
        let scene = DemonicFlipperScene(size: CGSize(width: 393, height: 852))
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            SpriteView(scene: scene)
                .ignoresSafeArea()

            InfernoOverlay(isActive: gameState.infernoModeActive)
                .allowsHitTesting(false)

            VStack {
                GameHUD(gameState: gameState) {
                    gameState.isPaused = true
                    scene.isPaused = true
                }
                .padding(.top, 8)

                Spacer()

                LaunchControls(scene: scene)
            }

            if gameState.isPaused {
                PauseMenuView(
                    onResume: {
                        gameState.isPaused = false
                        scene.isPaused = false
                    },
                    onMainMenu: {
                        scene.isPaused = false
                        router.route = .menu
                    }
                )
            }

            if gameState.isGameOver {
                GameOverView(
                    score: gameState.score,
                    highScore: highScoreStore.bestScore,
                    onReplay: {
                        scene.startNewGame()
                    },
                    onMainMenu: {
                        router.route = .menu
                    }
                )
            }
        }
        .statusBarHidden()
        .onAppear {
            scene.gameState = gameState
        }
        .onChange(of: gameState.isGameOver) { _, isOver in
            if isOver {
                highScoreStore.submit(score: gameState.score)
            }
        }
    }
}
