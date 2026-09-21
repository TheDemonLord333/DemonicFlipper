//
//  MenuButton.swift
//  Demonic Flipper
//

import SwiftUI
import UIKit

/// Shared button style for every menu-like screen in the game.
struct MenuButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button {
            if AppSettings.hapticsEnabled {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            action()
        } label: {
            HStack {
                Image(systemName: systemImage)
                Text(title.uppercased())
                    .font(DemonicFont.heading(size: 18))
                    .tracking(2)
                Spacer()
            }
            .foregroundStyle(DemonicPalette.steelSilver)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(DemonicPalette.charcoal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(DemonicPalette.bloodRed, lineWidth: 1.5)
                    )
                    .shadow(color: DemonicPalette.neonRed.opacity(0.35), radius: 10)
            )
        }
        .buttonStyle(.plain)
    }
}
