//
//  ParticleFactory.swift
//  Demonic Flipper
//

import SpriteKit
import UIKit

/// All particle textures are generated at runtime with Core Graphics,
/// so the game never depends on image assets that might be missing.
enum ParticleTextureFactory {
    private static var cache: [String: SKTexture] = [:]

    static func softCircle(diameter: CGFloat, color: UIColor) -> SKTexture {
        let key = "\(diameter)-\(color)"
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            let colors = [color.withAlphaComponent(0.95).cgColor, color.withAlphaComponent(0).cgColor]
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            ) else { return }
            let center = CGPoint(x: diameter / 2, y: diameter / 2)
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: center, startRadius: 0,
                endCenter: center, endRadius: diameter / 2,
                options: []
            )
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }
}

enum ParticleFactory {
    /// Slow embers drifting up from the bottom of the playfield.
    static func embers() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.softCircle(diameter: 24, color: DemonicPalette.uiEmberOrange)
        emitter.particleBirthRate = 5
        emitter.particleLifetime = 6
        emitter.particleLifetimeRange = 2.5
        emitter.particleSpeed = 34
        emitter.particleSpeedRange = 18
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 10
        emitter.particleAlpha = 0.75
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.12
        emitter.particleScale = 0.35
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.04
        emitter.particleBlendMode = .add
        return emitter
    }

    /// Faint rising smoke used as ambient background texture.
    static func smoke() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.softCircle(diameter: 70, color: UIColor(white: 0.35, alpha: 1))
        emitter.particleBirthRate = 1.5
        emitter.particleLifetime = 9
        emitter.particleLifetimeRange = 3
        emitter.particleSpeed = 8
        emitter.particleSpeedRange = 4
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 8
        emitter.particleAlpha = 0.10
        emitter.particleAlphaRange = 0.05
        emitter.particleScale = 1.1
        emitter.particleScaleRange = 0.4
        emitter.particleScaleSpeed = 0.12
        emitter.particleBlendMode = .alpha
        return emitter
    }

    /// A short, self-removing burst used when a target is hit.
    static func burst(at position: CGPoint, color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position
        emitter.particleTexture = ParticleTextureFactory.softCircle(diameter: 20, color: color)
        emitter.particleBirthRate = 500
        emitter.numParticlesToEmit = 22
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.25
        emitter.particleSpeed = 110
        emitter.particleSpeedRange = 60
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        emitter.particleAlpha = 0.9
        emitter.particleAlphaSpeed = -1.6
        emitter.particleScale = 0.4
        emitter.particleScaleSpeed = -0.5
        emitter.particleBlendMode = .add
        emitter.run(.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
        return emitter
    }
}
