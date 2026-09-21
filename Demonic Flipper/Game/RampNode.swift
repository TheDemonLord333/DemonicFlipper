//
//  RampNode.swift
//  Demonic Flipper
//

import SpriteKit

/// The "Höllenrampe": a physical curved guide the ball can roll
/// along, with a sensor at its exit that scores and lights a rune.
final class RampNode: SKNode {
    private let rune: RuneNode

    init(guidePath: CGPath, exitPoint: CGPoint) {
        let visual = SKShapeNode(path: guidePath)
        visual.strokeColor = DemonicPalette.uiViolet
        visual.lineWidth = 5
        visual.glowWidth = 8
        visual.lineCap = .round
        visual.fillColor = .clear

        let guideBody = SKPhysicsBody(edgeChainFrom: guidePath)
        guideBody.categoryBitMask = PhysicsCategory.wall
        guideBody.collisionBitMask = PhysicsCategory.ball
        guideBody.friction = 0.05
        guideBody.restitution = 0.25
        visual.physicsBody = guideBody

        let sensor = SKNode()
        sensor.position = exitPoint
        let sensorBody = SKPhysicsBody(circleOfRadius: 16)
        sensorBody.isDynamic = false
        sensorBody.categoryBitMask = PhysicsCategory.rampSensor
        sensorBody.collisionBitMask = PhysicsCategory.none
        sensorBody.contactTestBitMask = PhysicsCategory.ball
        sensor.physicsBody = sensorBody

        rune = RuneNode(radius: 12, style: RuneID.hellRamp.rawValue)
        rune.position = exitPoint

        super.init()
        addChild(visual)
        addChild(sensor)
        addChild(rune)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func lightRune() { rune.light() }
    func resetRune() { rune.reset() }
}
