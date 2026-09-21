//
//  LaunchControls.swift
//  Demonic Flipper
//

import SwiftUI

/// The plunger ("Abschuss") and nudge ("Dämonischer Schutz" nudge)
/// controls docked at the bottom of the playfield.
struct LaunchControls: View {
    let scene: DemonicFlipperScene

    var body: some View {
        HStack {
            Button {
                scene.nudge()
            } label: {
                Text("NUDGE")
                    .font(DemonicFont.heading(size: 12))
                    .foregroundStyle(DemonicPalette.steelSilver)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(DemonicPalette.charcoal.opacity(0.85))
                            .overlay(Capsule().stroke(DemonicPalette.violet, lineWidth: 1.5))
                    )
            }
            .padding(.leading, 24)

            Spacer()

            Button {
                scene.launchBall()
            } label: {
                Text("ABSCHUSS")
                    .font(DemonicFont.heading(size: 14))
                    .foregroundStyle(DemonicPalette.steelSilver)
                    .padding()
                    .background(
                        Circle()
                            .fill(DemonicPalette.bloodRed)
                            .overlay(Circle().stroke(DemonicPalette.neonRed, lineWidth: 2))
                    )
            }
            .padding(.trailing, 24)
        }
        .padding(.bottom, 24)
    }
}
