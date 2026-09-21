//
//  FlipperNode.swift
//  Demonic Flipper
//

import SpriteKit

/// A black-metal flipper with a glowing rune stripe. Pinned to a
/// static anchor by the scene via `SKPhysicsJointPin`, and driven
/// between a resting and an active angle with angular velocity so
/// the physics engine computes realistic impacts against the ball.
final class FlipperNode: SKNode {
    let isLeft: Bool
    private let restAngle: CGFloat
    private let activeAngle: CGFloat
    private let bodyShape: SKShapeNode
    private let runeStripe: SKShapeNode
    private var isPressed = false

    init(isLeft: Bool, length: CGFloat, thickness: CGFloat) {
        self.isLeft = isLeft
        let sign: CGFloat = isLeft ? 1 : -1
        let swing: CGFloat = 0.55
        self.restAngle = -sign * swing
        self.activeAngle = sign * swing

        let rect: CGRect = isLeft
            ? CGRect(x: 0, y: -thickness / 2, width: length, height: thickness)
            : CGRect(x: -length, y: -thickness / 2, width: length, height: thickness)
        let path = CGPath(roundedRect: rect, cornerWidth: thickness / 2, cornerHeight: thickness / 2, transform: nil)

        bodyShape = SKShapeNode(path: path)
        bodyShape.fillColor = DemonicPalette.uiCharcoal
        bodyShape.strokeColor = UIColor.black
        bodyShape.lineWidth = 1.5

        let stripeRect = rect.insetBy(dx: length * 0.12, dy: thickness * 0.32)
        runeStripe = SKShapeNode(rect: stripeRect, cornerRadius: thickness * 0.2)
        runeStripe.fillColor = .clear
        runeStripe.strokeColor = DemonicPalette.uiNeonRed
        runeStripe.lineWidth = 1.5
        runeStripe.glowWidth = 3

        super.init()
        addChild(bodyShape)
        addChild(runeStripe)
        zRotation = restAngle

        let physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = true
        physicsBody.mass = 0.6
        physicsBody.restitution = 0.15
        physicsBody.friction = 0.4
        physicsBody.categoryBitMask = PhysicsCategory.flipper
        physicsBody.collisionBitMask = PhysicsCategory.ball
        physicsBody.contactTestBitMask = PhysicsCategory.none
        self.physicsBody = physicsBody
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Swings the flipper toward its active angle and briefly
    /// brightens the rune stripe.
    func press() {
        guard !isPressed else { return }
        isPressed = true
        physicsBody?.angularVelocity = isLeft ? 22 : -22
        runeStripe.run(.sequence([
            .fadeAlpha(to: 1.0, duration: 0.05)
        ]))
        runeStripe.glowWidth = 8
    }

    /// Swings the flipper back toward its resting angle.
    func release() {
        guard isPressed else { return }
        isPressed = false
        physicsBody?.angularVelocity = isLeft ? -14 : 14
        runeStripe.glowWidth = 3
    }

    /// Called every frame by the scene to keep the flipper within
    /// its physical swing range (SpriteKit's pin joint has no
    /// built-in rotation limits).
    func clampRotation() {
        let minAngle = min(restAngle, activeAngle)
        let maxAngle = max(restAngle, activeAngle)
        if zRotation < minAngle {
            zRotation = minAngle
            physicsBody?.angularVelocity = 0
        } else if zRotation > maxAngle {
            zRotation = maxAngle
            physicsBody?.angularVelocity = 0
        }
    }
}
