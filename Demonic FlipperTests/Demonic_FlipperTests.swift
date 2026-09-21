//
//  Demonic_FlipperTests.swift
//  Demonic FlipperTests
//
//  Created by David Martens on 21.09.26.
//

import Testing
@testable import Demonic_Flipper

@MainActor
struct Demonic_FlipperTests {

    @Test func lightingAllRunesStartsInfernoMode() async throws {
        let state = GameState()
        for rune in RuneID.allCases.dropLast() {
            state.lightRune(rune)
            #expect(state.infernoModeActive == false)
        }
        state.lightRune(RuneID.allCases.last!)
        #expect(state.infernoModeActive == true)
        #expect(state.litRunes.isEmpty)
    }

    @Test func ballDrainedEndsGameAfterLastBall() async throws {
        let state = GameState()
        state.ballsRemaining = 1
        let gameOver = state.ballDrained()
        #expect(gameOver == true)
        #expect(state.isGameOver == true)
    }

    @Test func highScoreStoreKeepsTopTenDescending() async throws {
        let suiteName = "DemonicFlipperTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = HighScoreStore(defaults: defaults)
        for score in [100, 500, 250] {
            store.submit(score: score)
        }
        #expect(store.bestScore == 500)
        #expect(store.topScores == [500, 250, 100])
        defaults.removePersistentDomain(forName: suiteName)
    }

}
