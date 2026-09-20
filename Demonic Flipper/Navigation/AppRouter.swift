//
//  AppRouter.swift
//  Demonic Flipper
//

import SwiftUI

enum AppRoute {
    case menu
    case game
    case highScores
    case settings
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var route: AppRoute = .menu
}
