//
//  CoreTextureGenerator.swift
//  Tend
//
//  Generates textures programmatically for the Radiant Core visual layers.
//  Uses Core Graphics to create smooth gradients and organic shapes.
//

import SpriteKit
import UIKit

/// Generates textures for CoreNode layers programmatically.
/// This allows runtime iteration and can be replaced with image assets later.
final class CoreTextureGenerator {

    // MARK: - Singleton

    static let shared = CoreTextureGenerator()

    private init() {}

    // MARK: - Texture Cache

    private var textureCache: [String: SKTexture] = [:]

    // MARK: - Glow Texture

    /// Generates a soft radial gradient for glow/halo effects
    /// - Parameters:
    ///   - size: Texture size in points
    ///   - falloff: How quickly the glow fades (0.3 = soft, 0.8 = sharp)
    /// - Returns: SKTexture with radial gradient
    func generateGlowTexture(size: CGSize, falloff: CGFloat = 0.5) -> SKTexture {
        let cacheKey = "glow_\(Int(size.width))_\(falloff)"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2

            // Create radial gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(1 - falloff).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0, falloff, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: .drawsAfterEndLocation
                )
            }
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Surface Texture

    /// Generates an organic surface texture with subtle noise
    /// - Parameter size: Texture size in points
    /// - Returns: SKTexture with organic surface appearance
    func generateSurfaceTexture(size: CGSize) -> SKTexture {
        let cacheKey = "surface_\(Int(size.width))"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2

            // Create slightly irregular ellipse path for organic feel
            let path = CGMutablePath()
            let points = 64
            for i in 0..<points {
                let angle = (CGFloat(i) / CGFloat(points)) * 2 * .pi
                // Add subtle variation to radius (±3%)
                let variation = 1.0 + 0.03 * sin(angle * 5) * cos(angle * 3)
                let r = radius * 0.9 * variation
                let x = center.x + r * cos(angle)
                let y = center.y + r * sin(angle)

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()

            // Create radial gradient fill
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.withAlphaComponent(0.9).cgColor,
                UIColor.white.withAlphaComponent(0.7).cgColor,
                UIColor.white.withAlphaComponent(0.5).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0, 0.5, 1.0]

            cgContext.addPath(path)
            cgContext.clip()

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: center.x - radius * 0.2, y: center.y + radius * 0.2),
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: .drawsAfterEndLocation
                )
            }
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Inner Core Texture

    /// Generates a bright concentrated point for the inner core
    /// - Parameter size: Texture size in points
    /// - Returns: SKTexture with bright center point
    func generateInnerCoreTexture(size: CGSize) -> SKTexture {
        let cacheKey = "inner_\(Int(size.width))"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            // Offset center slightly for organic feel (per spec: "slightly off-center")
            let center = CGPoint(x: size.width * 0.48, y: size.height * 0.52)
            let radius = min(size.width, size.height) / 2

            // Create concentrated radial gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.95).cgColor,
                UIColor.white.withAlphaComponent(0.6).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0, 0.15, 0.4, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: .drawsAfterEndLocation
                )
            }
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Striation Texture

    /// Generates light channel patterns that cross the surface
    /// - Parameter size: Texture size in points
    /// - Returns: SKTexture with vein-like striations
    func generateStriationTexture(size: CGSize) -> SKTexture {
        let cacheKey = "striation_\(Int(size.width))"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 * 0.85

            cgContext.setBlendMode(.normal)

            // Draw several striation lines emanating from near-center
            let striationCount = 7
            for i in 0..<striationCount {
                let baseAngle = (CGFloat(i) / CGFloat(striationCount)) * 2 * .pi
                let angleVariation = CGFloat.random(in: -0.15...0.15)
                let angle = baseAngle + angleVariation

                // Create curved path from near-center outward
                let path = CGMutablePath()
                let startRadius = radius * 0.2
                let endRadius = radius * CGFloat.random(in: 0.7...0.95)

                let startPoint = CGPoint(
                    x: center.x + startRadius * cos(angle),
                    y: center.y + startRadius * sin(angle)
                )
                let endPoint = CGPoint(
                    x: center.x + endRadius * cos(angle + 0.1),
                    y: center.y + endRadius * sin(angle + 0.1)
                )

                // Control point for slight curve
                let controlRadius = (startRadius + endRadius) / 2
                let controlAngle = angle + CGFloat.random(in: -0.2...0.2)
                let controlPoint = CGPoint(
                    x: center.x + controlRadius * cos(controlAngle),
                    y: center.y + controlRadius * sin(controlAngle)
                )

                path.move(to: startPoint)
                path.addQuadCurve(to: endPoint, control: controlPoint)

                // Draw with gradient stroke
                cgContext.addPath(path)
                cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
                cgContext.setLineWidth(CGFloat.random(in: 2...4))
                cgContext.setLineCap(.round)
                cgContext.strokePath()
            }
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Particle Texture

    /// Generates a small circular texture for particles (sparks, embers)
    /// - Parameter size: Texture size in points
    /// - Returns: SKTexture for particle systems
    func generateParticleTexture(size: CGSize) -> SKTexture {
        let cacheKey = "particle_\(Int(size.width))"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.7).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0, 0.3, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: .drawsAfterEndLocation
                )
            }
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Cache Management

    /// Clears the texture cache to free memory
    func clearCache() {
        textureCache.removeAll()
    }
}
