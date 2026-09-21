//
//  SoulSealNode.swift
//  Demonic Flipper
//

import SpriteKit

/// The "Seelensiegel": a small, high-value skull-like target that is
/// the hardest to hit and awards the biggest bonus.
final class SoulSealNode: SKNode {
    private let core: SKShapeNode
    private let rune: RuneNode

    init(radius: CGFloat) {
        core = SKShapeNode(ellipseOf: CGSize(width: radius * 2, height: radius * 1.8))
        core.fillColor = DemonicPalette.uiViolet
        core.strokeColor = DemonicPalette.uiNeonRed
        core.lineWidth = 2
        core.glowWidth = 8

        let eyeRadius = radius * 0.22
        let leftEye = SKShapeNode(circleOfRadius: eyeRadius)
        leftEye.fillColor = DemonicPalette.uiAbyssBlack
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -radius * 0.35, y: radius * 0.05)

        let rightEye = SKShapeNode(circleOfRadius: eyeRadius)
        rightEye.fillColor = DemonicPalette.uiAbyssBlack
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: radius * 0.35, y: radius * 0.05)

        rune = RuneNode(radius: radius * 1.1, style: RuneID.soulSeal.rawValue)

        super.init()
        addChild(rune)
        addChild(core)
        core.addChild(leftEye)
        core.addChild(rightEye)

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.restitution = 0.6
        body.categoryBitMask = PhysicsCategory.soulSeal
        body.collisionBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func lightRune() { rune.light() }
    func resetRune() { rune.reset() }

    func pulse() {
        core.run(.sequence([
            .scale(to: 1.3, duration: 0.1),
            .scale(to: 1.0, duration: 0.15)
        ]))
    }
}
