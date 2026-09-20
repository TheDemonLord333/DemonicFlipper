//
//  RuneNode.swift
//  Demonic Flipper
//

import SpriteKit

/// A small programmatic rune glyph that brightens and pulses once lit.
final class RuneNode: SKNode {
    private let glyph: SKShapeNode
    private(set) var isLit = false

    init(radius: CGFloat, style: Int) {
        glyph = SKShapeNode(path: RuneNode.path(for: style, radius: radius))
        glyph.strokeColor = DemonicPalette.uiSteelSilver.withAlphaComponent(0.7)
        glyph.lineWidth = 2
        glyph.glowWidth = 0
        glyph.fillColor = .clear
        glyph.lineCap = .round
        super.init()
        addChild(glyph)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func light() {
        guard !isLit else { return }
        isLit = true
        glyph.strokeColor = DemonicPalette.uiNeonRed
        glyph.glowWidth = 6
        glyph.run(.sequence([
            .scale(to: 1.3, duration: 0.15),
            .scale(to: 1.0, duration: 0.15)
        ]))
    }

    func reset() {
        isLit = false
        glyph.strokeColor = DemonicPalette.uiSteelSilver.withAlphaComponent(0.7)
        glyph.glowWidth = 0
        glyph.setScale(1.0)
    }

    private static func path(for style: Int, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        switch abs(style) % 3 {
        case 0:
            path.move(to: CGPoint(x: 0, y: -radius))
            path.addLine(to: CGPoint(x: 0, y: radius))
            path.move(to: CGPoint(x: -radius, y: 0))
            path.addLine(to: CGPoint(x: radius, y: 0))
        case 1:
            path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))
        default:
            path.move(to: CGPoint(x: -radius, y: -radius))
            path.addLine(to: CGPoint(x: 0, y: radius))
            path.addLine(to: CGPoint(x: radius, y: -radius))
            path.closeSubpath()
        }
        return path
    }
}
