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

    // MARK: - Granulation / Convection Texture

    func generateGranulationTexture(size: CGSize, seed: Int) -> SKTexture {
        let cacheKey = "granulation_\(Int(size.width))_\(Int(size.height))_\(seed)"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        var rng = SeededRandomNumberGenerator(seed: UInt64(seed))
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setBlendMode(.plusLighter)

            let area = size.width * size.height
            let rawCount = Int(area / 240)
            let cellCount = max(70, min(180, rawCount))

            let minR = min(size.width, size.height) * 0.03
            let maxR = min(size.width, size.height) * 0.12

            for _ in 0..<cellCount {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let r = CGFloat.random(in: minR...maxR, using: &rng)
                let baseAlpha = CGFloat.random(in: 0.10...0.34, using: &rng)

                for pass in 0..<3 {
                    let t = CGFloat(pass) / 2
                    let rr = r * (1 + t * 0.9)
                    let a = baseAlpha * (1 - t) * (1 - t)
                    cgContext.setFillColor(UIColor.white.withAlphaComponent(a).cgColor)
                    cgContext.fillEllipse(in: CGRect(x: x - rr, y: y - rr, width: rr * 2, height: rr * 2))
                }
            }

            // Mild edge falloff so motion reads more "inside" the core.
            cgContext.setBlendMode(.destinationIn)
            let insetRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.withAlphaComponent(0).cgColor,
                UIColor.white.withAlphaComponent(1).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor,
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    startRadius: 0,
                    endCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    endRadius: min(size.width, size.height) / 2,
                    options: .drawsAfterEndLocation
                )
            }
            cgContext.setBlendMode(.normal)
            cgContext.addRect(insetRect)
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Sweep Band Texture (for striation energy)

    func generateSweepBandTexture(size: CGSize) -> SKTexture {
        let cacheKey = "sweepband_\(Int(size.width))_\(Int(size.height))"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.withAlphaComponent(0.0).cgColor,
                UIColor.white.withAlphaComponent(0.18).cgColor,
                UIColor.white.withAlphaComponent(0.85).cgColor,
                UIColor.white.withAlphaComponent(0.18).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.44, 0.5, 0.56, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: size.height / 2),
                    end: CGPoint(x: size.width, y: size.height / 2),
                    options: []
                )
            }

            // Feather vertically a bit so it reads like a band, not a bar.
            let vColors = [
                UIColor.white.withAlphaComponent(0.0).cgColor,
                UIColor.white.withAlphaComponent(1.0).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ] as CFArray
            let vLocations: [CGFloat] = [0.0, 0.5, 1.0]
            cgContext.setBlendMode(.destinationIn)
            if let vGradient = CGGradient(colorsSpace: colorSpace, colors: vColors, locations: vLocations) {
                cgContext.drawLinearGradient(
                    vGradient,
                    start: CGPoint(x: size.width / 2, y: 0),
                    end: CGPoint(x: size.width / 2, y: size.height),
                    options: []
                )
            }
            cgContext.setBlendMode(.normal)
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

    func generateStreakParticleTexture(size: CGSize) -> SKTexture {
        let cacheKey = "streak_\(Int(size.width))_\(Int(size.height))"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: size.height / 2)
            cgContext.addPath(path.cgPath)
            cgContext.clip()

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.withAlphaComponent(0).cgColor,
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0).cgColor,
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.5, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: size.height / 2),
                    end: CGPoint(x: size.width, y: size.height / 2),
                    options: []
                )
            }
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Ring Texture

    func generateRingTexture(size: CGSize) -> SKTexture {
        let cacheKey = "ring_\(Int(size.width))_\(Int(size.height))"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setBlendMode(.plusLighter)
            cgContext.setLineCap(.round)

            let baseWidth = min(size.width, size.height) * 0.065
            for pass in 0..<3 {
                let t = CGFloat(pass) / 2
                let width = baseWidth * (1 + t * 1.4)
                let alpha = (0.85 * (1 - t)).clamped(to: 0...1)
                let inset = width / 2 + 1
                let rect = CGRect(x: inset, y: inset, width: size.width - inset * 2, height: size.height - inset * 2)

                cgContext.setStrokeColor(UIColor.white.withAlphaComponent(alpha).cgColor)
                cgContext.setLineWidth(width)
                cgContext.strokeEllipse(in: rect)
            }
        }

        let texture = SKTexture(image: image)
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Apex Flare Texture

    func generateApexFlareTexture(size: CGSize, seed: Int) -> SKTexture {
        let cacheKey = "apexflare_\(Int(size.width))_\(Int(size.height))_\(seed)"
        if let cached = textureCache[cacheKey] {
            return cached
        }

        var rng = SeededRandomNumberGenerator(seed: UInt64(seed))
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            cgContext.setBlendMode(.plusLighter)
            cgContext.setLineCap(.round)

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) / 2

            // Soft bloom under the rays
            let bloomColors = [
                UIColor.white.withAlphaComponent(0.0).cgColor,
                UIColor.white.withAlphaComponent(0.35).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ] as CFArray
            let bloomLocations: [CGFloat] = [0.0, 0.55, 1.0]
            if let bloom = CGGradient(colorsSpace: colorSpace, colors: bloomColors, locations: bloomLocations) {
                cgContext.drawRadialGradient(
                    bloom,
                    startCenter: center,
                    startRadius: r * 0.08,
                    endCenter: center,
                    endRadius: r,
                    options: .drawsAfterEndLocation
                )
            }

            // Radial rays (soft solar flare language)
            let rayCount = 44
            for i in 0..<rayCount {
                let t = CGFloat(i) / CGFloat(rayCount)
                let jitter = CGFloat.random(in: -0.04...0.04, using: &rng)
                let angle = (t * 2 * .pi) + jitter

                let innerR = r * CGFloat.random(in: 0.18...0.32, using: &rng)
                let len = r * CGFloat.random(in: 0.28...0.60, using: &rng)
                let outerR = (innerR + len).clamped(to: 0...r * 1.05)

                let sx = center.x + cos(angle) * innerR
                let sy = center.y + sin(angle) * innerR
                let ex = center.x + cos(angle) * outerR
                let ey = center.y + sin(angle) * outerR

                let w = CGFloat.random(in: 2.0...3.6, using: &rng)
                let a = CGFloat.random(in: 0.22...0.70, using: &rng)

                // Bright core ray
                cgContext.setStrokeColor(UIColor.white.withAlphaComponent(a).cgColor)
                cgContext.setLineWidth(w)
                cgContext.beginPath()
                cgContext.move(to: CGPoint(x: sx, y: sy))
                cgContext.addLine(to: CGPoint(x: ex, y: ey))
                cgContext.strokePath()

                // Soft halo ray
                cgContext.setStrokeColor(UIColor.white.withAlphaComponent(a * 0.22).cgColor)
                cgContext.setLineWidth(w * 2.6)
                cgContext.beginPath()
                cgContext.move(to: CGPoint(x: sx, y: sy))
                cgContext.addLine(to: CGPoint(x: ex, y: ey))
                cgContext.strokePath()
            }

            // Mask: ring-shaped falloff so it doesn't blow out the core center
            cgContext.setBlendMode(.destinationIn)
            let maskColors = [
                UIColor.white.withAlphaComponent(0.06).cgColor,
                UIColor.white.withAlphaComponent(1.0).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ] as CFArray
            let maskLocations: [CGFloat] = [0.0, 0.42, 1.0]
            if let mask = CGGradient(colorsSpace: colorSpace, colors: maskColors, locations: maskLocations) {
                cgContext.drawRadialGradient(
                    mask,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: r,
                    options: .drawsAfterEndLocation
                )
            }
            cgContext.setBlendMode(.normal)
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

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x4d595df4d0f33173 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}
