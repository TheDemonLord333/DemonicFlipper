//
//  DemonicFlipperScene.swift
//  Demonic Flipper
//

import SpriteKit
import UIKit

/// The SpriteKit playfield: a dark fortress with a launch lane on the
/// right, three demon-sigil bumpers, a Höllenrampe, a Seelensiegel,
/// two rune-etched flippers, and an open drain at the bottom.
final class DemonicFlipperScene: SKScene, SKPhysicsContactDelegate {
    /// Set by the hosting SwiftUI view. Triggers a fresh game once
    /// both the scene has finished building its field and a state
    /// object has been provided, whichever happens last.
    var gameState: GameState? {
        didSet {
            guard isSceneReady, gameState != nil else { return }
            startNewGame()
        }
    }

    private var isSceneReady = false
    private var isBallInPlay = false
    private var lastUpdateTime: TimeInterval = 0
    private var wasInfernoActive = false

    private var ball: SKShapeNode!
    private var launchPosition: CGPoint = .zero
    private var flippers: [FlipperNode] = []
    private var bumpers: [BumperNode] = []
    private var ramp: RampNode?
    private var soulSeal: SoulSealNode?

    private var leftTouches: Set<UITouch> = []
    private var rightTouches: Set<UITouch> = []
    private var leftWasPressed = false
    private var rightWasPressed = false

    private lazy var infernoOverlay: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: -40, y: -40, width: size.width + 80, height: size.height + 80))
        node.fillColor = DemonicPalette.uiNeonRed.withAlphaComponent(0.14)
        node.strokeColor = .clear
        node.blendMode = .add
        node.zPosition = 60
        node.alpha = 0
        node.isUserInteractionEnabled = false
        return node
    }()

    // MARK: - Field layout

    private struct FieldLayout {
        let width: CGFloat
        let height: CGFloat
        let margin: CGFloat
        let laneWidth: CGFloat
        let bottomOpenY: CGFloat
        let laneTopOpeningY: CGFloat
        let fieldLeft: CGFloat
        let fieldRight: CGFloat
        let fieldWidth: CGFloat

        init(size: CGSize) {
            width = size.width
            height = size.height
            margin = 14
            laneWidth = 54
            bottomOpenY = height * 0.05
            laneTopOpeningY = height - margin - 90
            fieldLeft = margin
            fieldRight = width - margin - laneWidth
            fieldWidth = fieldRight - fieldLeft
        }
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = true
        backgroundColor = DemonicPalette.uiAbyssBlack
        physicsWorld.gravity = CGVector(dx: 0, dy: -6.2)
        physicsWorld.contactDelegate = self
        buildField()
        isSceneReady = true
        if gameState != nil {
            startNewGame()
        }
    }

    private func buildField() {
        removeAllChildren()
        flippers.removeAll()
        bumpers.removeAll()

        let layout = FieldLayout(size: size)

        let boundary = SKNode()
        let boundaryBody = SKPhysicsBody(edgeChainFrom: makeBoundaryPath(layout: layout))
        boundaryBody.categoryBitMask = PhysicsCategory.wall
        boundaryBody.friction = 0.2
        boundaryBody.restitution = 0.35
        boundary.physicsBody = boundaryBody
        addChild(boundary)

        addBackgroundDecoration(layout: layout)
        addBumpers(layout: layout)
        addRamp(layout: layout)
        addSoulSeal(layout: layout)
        addFlippers(layout: layout)
        addBall(layout: layout)
        addChild(infernoOverlay)
    }

    private func makeBoundaryPath(layout: FieldLayout) -> CGPath {
        let path = CGMutablePath()

        // Left wall + top wall of the main field, down to where the
        // launch lane's inner wall begins.
        path.move(to: CGPoint(x: layout.margin, y: layout.bottomOpenY))
        path.addLine(to: CGPoint(x: layout.margin, y: layout.height - layout.margin))
        path.addLine(to: CGPoint(x: layout.fieldRight, y: layout.height - layout.margin))

        // Inner lane wall: stops short of the top so a launched ball
        // can crest over it into the main field.
        path.move(to: CGPoint(x: layout.fieldRight, y: layout.bottomOpenY))
        path.addLine(to: CGPoint(x: layout.fieldRight, y: layout.laneTopOpeningY))

        // Outer lane wall + lane top cap.
        path.move(to: CGPoint(x: layout.fieldRight, y: layout.height - layout.margin))
        path.addLine(to: CGPoint(x: layout.width - layout.margin, y: layout.height - layout.margin))
        path.addLine(to: CGPoint(x: layout.width - layout.margin, y: layout.bottomOpenY))

        // Lane floor (the main field's bottom stays open as the drain).
        path.move(to: CGPoint(x: layout.fieldRight, y: layout.bottomOpenY))
        path.addLine(to: CGPoint(x: layout.width - layout.margin, y: layout.bottomOpenY))

        return path
    }

    private func addBackgroundDecoration(layout: FieldLayout) {
        let embers = ParticleFactory.embers()
        embers.position = CGPoint(x: layout.width / 2, y: layout.bottomOpenY)
        embers.particlePositionRange = CGVector(dx: layout.width, dy: 0)
        embers.zPosition = 5
        addChild(embers)

        let smoke = ParticleFactory.smoke()
        smoke.position = CGPoint(x: layout.width / 2, y: layout.height * 0.92)
        smoke.particlePositionRange = CGVector(dx: layout.fieldWidth * 0.6, dy: 0)
        smoke.zPosition = 5
        addChild(smoke)

        addChild(makeGateArch(layout: layout))
    }

    private func makeGateArch(layout: FieldLayout) -> SKNode {
        let container = SKNode()
        container.zPosition = 2

        let archWidth = layout.fieldWidth * 0.7
        let archHeight: CGFloat = 90
        let baseY = layout.height - 26
        let left = CGPoint(x: layout.fieldLeft + (layout.fieldWidth - archWidth) / 2, y: baseY - archHeight)
        let right = CGPoint(x: left.x + archWidth, y: baseY - archHeight)
        let top = CGPoint(x: layout.fieldLeft + layout.fieldWidth / 2, y: baseY)

        let archPath = CGMutablePath()
        archPath.move(to: left)
        archPath.addQuadCurve(to: top, control: CGPoint(x: left.x, y: baseY + 14))
        archPath.addQuadCurve(to: right, control: CGPoint(x: right.x, y: baseY + 14))

        let arch = SKShapeNode(path: archPath)
        arch.strokeColor = DemonicPalette.uiViolet
        arch.lineWidth = 4
        arch.glowWidth = 10
        arch.lineCap = .round
        arch.fillColor = .clear
        container.addChild(arch)

        return container
    }

    private func addBumpers(layout: FieldLayout) {
        let configs: [(CGPoint, RuneID)] = [
            (CGPoint(x: layout.fieldLeft + layout.fieldWidth * 0.32, y: layout.height * 0.60), .leftSigil),
            (CGPoint(x: layout.fieldLeft + layout.fieldWidth * 0.68, y: layout.height * 0.66), .rightSigil),
            (CGPoint(x: layout.fieldLeft + layout.fieldWidth * 0.48, y: layout.height * 0.48), .apexSigil)
        ]
        bumpers = configs.map { position, rune in
            let bumper = BumperNode(radius: 22, runeID: rune)
            bumper.position = position
            bumper.zPosition = 20
            addChild(bumper)
            return bumper
        }
    }

    private func addRamp(layout: FieldLayout) {
        let start = CGPoint(x: layout.fieldLeft + 26, y: layout.height * 0.22)
        let control = CGPoint(x: layout.fieldLeft + 76, y: layout.height * 0.5)
        let end = CGPoint(x: layout.fieldLeft + 30, y: layout.height * 0.82)

        let path = CGMutablePath()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)

        let rampNode = RampNode(guidePath: path, exitPoint: end)
        rampNode.zPosition = 15
        addChild(rampNode)
        ramp = rampNode
    }

    private func addSoulSeal(layout: FieldLayout) {
        let seal = SoulSealNode(radius: 15)
        seal.position = CGPoint(x: layout.fieldLeft + layout.fieldWidth * 0.52, y: layout.height * 0.88)
        seal.zPosition = 20
        addChild(seal)
        soulSeal = seal
    }

    private func addFlippers(layout: FieldLayout) {
        let length = layout.fieldWidth * 0.24
        let thickness: CGFloat = 15
        let leftPivot = CGPoint(x: layout.fieldLeft + layout.fieldWidth * 0.30, y: layout.bottomOpenY + 46)
        let rightPivot = CGPoint(x: layout.fieldLeft + layout.fieldWidth * 0.70, y: layout.bottomOpenY + 46)

        let left = FlipperNode(isLeft: true, length: length, thickness: thickness)
        let right = FlipperNode(isLeft: false, length: length, thickness: thickness)

        pinFlipper(left, at: leftPivot)
        pinFlipper(right, at: rightPivot)

        flippers = [left, right]
    }

    private func pinFlipper(_ flipper: FlipperNode, at position: CGPoint) {
        flipper.position = position
        flipper.zPosition = 30
        addChild(flipper)

        let pivot = SKNode()
        pivot.position = position
        let pivotBody = SKPhysicsBody(circleOfRadius: 1)
        pivotBody.isDynamic = false
        pivot.physicsBody = pivotBody
        addChild(pivot)

        guard let flipperBody = flipper.physicsBody else { return }
        let joint = SKPhysicsJointPin.joint(withBodyA: pivotBody, bodyB: flipperBody, anchor: position)
        physicsWorld.add(joint)
    }

    private func addBall(layout: FieldLayout) {
        let radius: CGFloat = 9
        let node = SKShapeNode(circleOfRadius: radius)
        node.name = "ball"
        node.fillColor = DemonicPalette.uiSteelSilver
        node.strokeColor = DemonicPalette.uiViolet
        node.lineWidth = 1
        node.glowWidth = 2
        node.zPosition = 50

        let highlight = SKShapeNode(circleOfRadius: radius * 0.32)
        highlight.fillColor = UIColor(white: 1, alpha: 0.5)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -radius * 0.3, y: radius * 0.3)
        node.addChild(highlight)

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.categoryBitMask = PhysicsCategory.ball
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.flipper | PhysicsCategory.bumper | PhysicsCategory.soulSeal
        body.contactTestBitMask = PhysicsCategory.bumper | PhysicsCategory.rampSensor | PhysicsCategory.soulSeal
        body.restitution = 0.35
        body.friction = 0.2
        body.linearDamping = 0.4
        body.angularDamping = 0.3
        body.mass = 0.15
        body.usesPreciseCollisionDetection = true
        node.physicsBody = body

        ball = node
        launchPosition = CGPoint(x: layout.fieldRight + layout.laneWidth / 2, y: layout.bottomOpenY + 24)
        ball.position = launchPosition
        addChild(ball)
    }

    // MARK: - Game flow

    func startNewGame() {
        gameState?.reset()
        isBallInPlay = false
        wasInfernoActive = false
        infernoOverlay.removeAllActions()
        infernoOverlay.alpha = 0
        for bumper in bumpers { bumper.resetRune() }
        ramp?.resetRune()
        soulSeal?.resetRune()
        resetBallToLaunch()
        isPaused = false
    }

    func launchBall() {
        guard let gameState, !isBallInPlay, !gameState.isPaused, !gameState.isGameOver else { return }
        isBallInPlay = true
        ball.physicsBody?.velocity = .zero
        ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 55))
        gameState.isBallSaveActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak gameState] in
            gameState?.isBallSaveActive = false
        }
    }

    /// A limited "Dämonischer Schutz" nudge: gently kicks the ball,
    /// but repeated nudging trips TILT.
    func nudge() {
        guard let gameState, !gameState.isTilted, !gameState.isPaused, !gameState.isGameOver else { return }
        ball.physicsBody?.applyImpulse(CGVector(dx: CGFloat.random(in: -16...16), dy: 10))
        nudgeCount += 1
        nudgeResetWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.nudgeCount = 0 }
        nudgeResetWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: work)
        if nudgeCount >= 3 {
            triggerTilt()
        }
    }

    private var nudgeCount = 0
    private var nudgeResetWorkItem: DispatchWorkItem?

    private func triggerTilt() {
        gameState?.tilt()
        for flipper in flippers { flipper.release() }
    }

    private func resetBallToLaunch() {
        ball.physicsBody?.velocity = .zero
        ball.physicsBody?.angularVelocity = 0
        ball.position = launchPosition
    }

    private func handleDrain() {
        isBallInPlay = false
        resetBallToLaunch()

        if gameState?.isBallSaveActive == true {
            gameState?.isBallSaveActive = false
            return
        }
        gameState?.ballDrained()
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameState, !gameState.isPaused, !gameState.isGameOver, !gameState.isTilted else { return }
        for touch in touches {
            if touch.location(in: self).x < size.width * 0.5 {
                leftTouches.insert(touch)
            } else {
                rightTouches.insert(touch)
            }
        }
        updateFlipperStates()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            leftTouches.remove(touch)
            rightTouches.remove(touch)
        }
        updateFlipperStates()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func updateFlipperStates() {
        let leftPressed = !leftTouches.isEmpty
        let rightPressed = !rightTouches.isEmpty

        for flipper in flippers {
            let shouldPress = flipper.isLeft ? leftPressed : rightPressed
            if shouldPress {
                flipper.press()
            } else {
                flipper.release()
            }
        }

        if leftPressed && !leftWasPressed { fireFlipperHaptic() }
        if rightPressed && !rightWasPressed { fireFlipperHaptic() }
        leftWasPressed = leftPressed
        rightWasPressed = rightPressed
    }

    private func fireFlipperHaptic() {
        guard AppSettings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        defer { lastUpdateTime = currentTime }
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime

        for flipper in flippers { flipper.clampRotation() }

        gameState?.tick(deltaTime: deltaTime)

        if let active = gameState?.infernoModeActive, active != wasInfernoActive {
            wasInfernoActive = active
            infernoOverlay.run(.fadeAlpha(to: active ? 1 : 0, duration: 0.4))
            if active {
                spawnBurst(at: CGPoint(x: size.width / 2, y: size.height / 2), color: DemonicPalette.uiEmberOrange)
            }
        }

        if isBallInPlay, ball.position.y < -40 {
            handleDrain()
        }
    }

    // MARK: - Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        guard let gameState, !gameState.isPaused else { return }
        let bodies = [contact.bodyA, contact.bodyB]
        guard bodies.contains(where: { $0.categoryBitMask == PhysicsCategory.ball }) else { return }
        guard let other = bodies.first(where: { $0.categoryBitMask != PhysicsCategory.ball }) else { return }

        switch other.categoryBitMask {
        case PhysicsCategory.bumper:
            guard let bumper = other.node as? BumperNode else { return }
            bumper.pulse()
            spawnBurst(at: bumper.position, color: DemonicPalette.uiNeonRed)
            gameState.registerHit(basePoints: 250)
            bumper.lightRune()
            gameState.lightRune(bumper.runeID)

        case PhysicsCategory.rampSensor:
            guard let rampNode = other.node?.parent as? RampNode else { return }
            spawnBurst(at: other.node?.position ?? .zero, color: DemonicPalette.uiViolet)
            gameState.registerHit(basePoints: 400)
            rampNode.lightRune()
            gameState.lightRune(.hellRamp)

        case PhysicsCategory.soulSeal:
            guard let seal = other.node as? SoulSealNode else { return }
            seal.pulse()
            spawnBurst(at: seal.position, color: DemonicPalette.uiEmberOrange)
            gameState.registerHit(basePoints: 1000)
            seal.lightRune()
            gameState.lightRune(.soulSeal)

        default:
            break
        }
    }

    private func spawnBurst(at position: CGPoint, color: UIColor) {
        let emitter = ParticleFactory.burst(at: position, color: color)
        emitter.zPosition = 45
        addChild(emitter)
    }
}
