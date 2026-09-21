//
//  PauseMenuView.swift
//  Demonic Flipper
//

import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onMainMenu: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("PAUSIERT")
                    .font(DemonicFont.title(size: 30))
                    .foregroundStyle(DemonicPalette.neonRed)

                VStack(spacing: 14) {
                    MenuButton(title: "Fortsetzen", systemImage: "play.fill", action: onResume)
                    MenuButton(title: "Hauptmenü", systemImage: "house.fill", action: onMainMenu)
                }
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
            .padding(.horizontal, 40)
        }
    }
}
