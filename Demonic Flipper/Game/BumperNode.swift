//
//  BumperNode.swift
//  Demonic Flipper
//

import SpriteKit

/// A glowing "Dämonensiegel" bumper. Bounces the ball and lights
/// its rune when hit.
final class BumperNode: SKNode {
    let runeID: RuneID
    private let core: SKShapeNode
    private let rune: RuneNode

    init(radius: CGFloat, runeID: RuneID) {
        self.runeID = runeID

        core = SKShapeNode(circleOfRadius: radius)
        core.fillColor = DemonicPalette.uiBloodRed
        core.strokeColor = DemonicPalette.uiNeonRed
        core.lineWidth = 3
        core.glowWidth = 6

        rune = RuneNode(radius: radius * 0.5, style: runeID.rawValue)

        super.init()
        addChild(core)
        addChild(rune)

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.restitution = 1.05
        body.categoryBitMask = PhysicsCategory.bumper
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
            .scale(to: 1.25, duration: 0.08),
            .scale(to: 1.0, duration: 0.12)
        ]))
    }
}
