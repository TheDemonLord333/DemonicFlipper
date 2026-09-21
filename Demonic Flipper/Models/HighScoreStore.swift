//
//  HighScoreStore.swift
//  Demonic Flipper
//

import Foundation

/// Persists the top scores ("geopferte Seelen") across launches.
@MainActor
final class HighScoreStore: ObservableObject {
    private let defaults: UserDefaults
    private let scoresKey = "demonicFlipper.topScores"

    @Published private(set) var topScores: [Int] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.topScores = defaults.array(forKey: scoresKey) as? [Int] ?? []
    }

    var bestScore: Int { topScores.first ?? 0 }

    func submit(score: Int) {
        guard score > 0 else { return }
        topScores.append(score)
        topScores.sort(by: >)
        topScores = Array(topScores.prefix(10))
        defaults.set(topScores, forKey: scoresKey)
    }

    func clear() {
        topScores = []
        defaults.removeObject(forKey: scoresKey)
    }
}
