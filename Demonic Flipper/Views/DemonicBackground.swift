//
//  DemonicBackground.swift
//  Demonic Flipper
//

import SwiftUI

/// Shared animated backdrop used by every non-gameplay screen: a
/// pulsing Höllentor glow, drifting embers, and a slowly rotating
/// ring of rune glyphs. Built entirely from SwiftUI gradients and
/// shapes, so it never depends on external art.
struct DemonicBackground: View {
    @State private var pulse = false
    @State private var emberPhase = false

    private let emberSeeds: [EmberSeed] = (0..<16).map { _ in EmberSeed() }

    var body: some View {
        ZStack {
            DemonicPalette.backgroundGradient
                .ignoresSafeArea()

            DemonicPalette.gateGradient
                .frame(width: 320, height: 420)
                .blur(radius: 40)
                .opacity(pulse ? 0.55 : 0.32)
                .ignoresSafeArea()

            GeometryReader { proxy in
                ZStack {
                    ForEach(emberSeeds) { seed in
                        EmberParticleView(seed: seed, bounds: proxy.size, phase: emberPhase)
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            RuneRingView(pulse: pulse)
                .opacity(0.32)
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                emberPhase = true
            }
        }
    }
}

private struct EmberSeed: Identifiable {
    let id = UUID()
    let xFraction = Double.random(in: 0...1)
    let delay = Double.random(in: 0...4)
    let duration = Double.random(in: 4...8)
    let size = Double.random(in: 2...5)
}

private struct EmberParticleView: View {
    let seed: EmberSeed
    let bounds: CGSize
    let phase: Bool

    var body: some View {
        Circle()
            .fill(DemonicPalette.emberOrange)
            .frame(width: seed.size, height: seed.size)
            .blur(radius: 0.6)
            .shadow(color: DemonicPalette.emberOrange, radius: 4)
            .position(
                x: seed.xFraction * bounds.width,
                y: phase ? -20 : bounds.height + 20
            )
            .opacity(phase ? 0 : 0.9)
            .animation(
                .easeIn(duration: seed.duration).repeatForever(autoreverses: false).delay(seed.delay),
                value: phase
            )
    }
}

private struct RuneRingView: View {
    let pulse: Bool

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                RuneGlyph(index: index)
                    .stroke(DemonicPalette.neonRed, lineWidth: 1.5)
                    .frame(width: 26, height: 26)
                    .shadow(color: DemonicPalette.neonRed, radius: pulse ? 6 : 2)
                    .offset(
                        x: CGFloat(cos(Double(index) / 6 * .pi * 2)) * 150,
                        y: CGFloat(sin(Double(index) / 6 * .pi * 2)) * 150
                    )
            }
        }
    }
}

private struct RuneGlyph: Shape {
    let index: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch index % 3 {
        case 0:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        case 1:
            path.addEllipse(in: rect.insetBy(dx: rect.width * 0.15, dy: rect.height * 0.15))
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        default:
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        return path
    }
}
