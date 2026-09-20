//
//  InfernoOverlay.swift
//  Demonic Flipper
//

import SwiftUI

/// A restrained "INFERNO MODE" banner shown while the bonus round
/// from a completed Seelenritual is active.
struct InfernoOverlay: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            if isActive {
                RadialGradient(
                    colors: [DemonicPalette.neonRed.opacity(0.22), .clear],
                    center: .center, startRadius: 100, endRadius: 500
                )
                .ignoresSafeArea()

                VStack {
                    Text("INFERNO MODE")
                        .font(DemonicFont.title(size: 24))
                        .foregroundStyle(DemonicPalette.emberOrange)
                        .shadow(color: DemonicPalette.neonRed, radius: 10)
                        .padding(.top, 60)
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isActive)
    }
}
