//
//  GameState.swift
//  Demonic Flipper
//

import Foundation

/// Drives all scoring, combo, multiplier, rune, and Inferno Mode
/// bookkeeping. The SpriteKit scene mutates this; every SwiftUI
/// screen observes it.
@MainActor
final class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var ballsRemaining: Int = 3
    @Published var multiplier: Int = 1
    @Published var comboCount: Int = 0
    @Published var comboActive: Bool = false
    @Published var isTilted: Bool = false
    @Published var litRunes: Set<RuneID> = []
    @Published var infernoModeActive: Bool = false
    @Published var infernoTimeRemaining: Double = 0
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var isBallSaveActive: Bool = false

    private let infernoDuration: Double = 18
    private var comboResetWorkItem: DispatchWorkItem?

    func reset() {
        score = 0
        ballsRemaining = 3
        multiplier = 1
        comboCount = 0
        comboActive = false
        isTilted = false
        litRunes = []
        infernoModeActive = false
        infernoTimeRemaining = 0
        isGameOver = false
        isPaused = false
        isBallSaveActive = false
        comboResetWorkItem?.cancel()
    }

    /// Awards points, respecting Demonic Multiplier and Inferno Mode,
    /// and refreshes the Hell Combo window.
    func registerHit(basePoints: Int) {
        guard !isTilted else { return }
        let infernoBonus = infernoModeActive ? 2 : 1
        score += basePoints * multiplier * infernoBonus
        registerCombo()
    }

    private func registerCombo() {
        comboCount += 1
        comboActive = true
        if comboCount > 0 && comboCount % 5 == 0 {
            multiplier = min(multiplier + 1, 5)
        }

        comboResetWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.comboActive = false
            self?.comboCount = 0
        }
        comboResetWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }

    /// Lights a rune of the "Seelenritual". Once every rune is lit,
    /// the Dämonentor opens and Inferno Mode begins.
    func lightRune(_ rune: RuneID) {
        guard !litRunes.contains(rune) else { return }
        litRunes.insert(rune)
        if litRunes.count == RuneID.allCases.count {
            startInfernoMode()
        }
    }

    func startInfernoMode() {
        guard !infernoModeActive else { return }
        infernoModeActive = true
        infernoTimeRemaining = infernoDuration
        litRunes = []
    }

    func tick(deltaTime: Double) {
        guard infernoModeActive else { return }
        infernoTimeRemaining -= deltaTime
        if infernoTimeRemaining <= 0 {
            infernoModeActive = false
            infernoTimeRemaining = 0
        }
    }

    func tilt() {
        isTilted = true
    }

    /// Returns `true` once the last ball is gone and the game has ended.
    @discardableResult
    func ballDrained() -> Bool {
        ballsRemaining -= 1
        isTilted = false
        multiplier = 1
        comboCount = 0
        comboActive = false
        if ballsRemaining <= 0 {
            isGameOver = true
            return true
        }
        return false
    }
}
