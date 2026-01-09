//
//  Interpolation.swift
//  Tend
//
//  Mathematical utility functions for smooth state interpolation.
//

import UIKit

// MARK: - Linear Interpolation

/// Linear interpolation between two values
/// - Parameters:
///   - a: Start value
///   - b: End value
///   - t: Interpolation factor (0.0 to 1.0)
/// - Returns: Interpolated value
func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    return a + (b - a) * t.clamped(to: 0...1)
}

/// Linear interpolation for Double values
func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
    return a + (b - a) * t.clamped(to: 0...1)
}

/// Linear interpolation for Float values
func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
    return a + (b - a) * t.clamped(to: 0...1)
}

// MARK: - Easing Functions

/// Quadratic ease-in-out curve
/// Provides smooth acceleration and deceleration
func easeInOutQuad(_ t: CGFloat) -> CGFloat {
    let clamped = t.clamped(to: 0...1)
    return clamped < 0.5
        ? 2 * clamped * clamped
        : 1 - pow(-2 * clamped + 2, 2) / 2
}

/// Cubic ease-in-out curve
/// Provides more pronounced acceleration/deceleration than quadratic
func easeInOutCubic(_ t: CGFloat) -> CGFloat {
    let clamped = t.clamped(to: 0...1)
    return clamped < 0.5
        ? 4 * clamped * clamped * clamped
        : 1 - pow(-2 * clamped + 2, 3) / 2
}

/// Sine ease-in-out curve
/// Provides very smooth, natural-feeling transitions
func easeInOutSine(_ t: CGFloat) -> CGFloat {
    let clamped = t.clamped(to: 0...1)
    return -(cos(.pi * clamped) - 1) / 2
}

/// Linear interpolation with quadratic easing
func lerpEased(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    return lerp(a, b, easeInOutQuad(t))
}

// MARK: - Color Interpolation

/// Interpolate between two colors in LAB color space for perceptually uniform transitions
/// - Parameters:
///   - from: Starting color
///   - to: Ending color
///   - t: Interpolation factor (0.0 to 1.0)
/// - Returns: Interpolated color
func lerpColor(_ from: UIColor, _ to: UIColor, _ t: CGFloat) -> UIColor {
    let clamped = t.clamped(to: 0...1)

    var fromL: CGFloat = 0, fromA: CGFloat = 0, fromB: CGFloat = 0, fromAlpha: CGFloat = 0
    var toL: CGFloat = 0, toA: CGFloat = 0, toB: CGFloat = 0, toAlpha: CGFloat = 0

    from.getLAB(&fromL, &fromA, &fromB, &fromAlpha)
    to.getLAB(&toL, &toA, &toB, &toAlpha)

    return UIColor(
        l: lerp(fromL, toL, clamped),
        a: lerp(fromA, toA, clamped),
        b: lerp(fromB, toB, clamped),
        alpha: lerp(fromAlpha, toAlpha, clamped)
    )
}

// MARK: - CGFloat Extension

extension CGFloat {
    /// Clamp value to a closed range
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Double {
    /// Clamp value to a closed range
    func clamped(to range: ClosedRange<Double>) -> Double {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Float {
    /// Clamp value to a closed range
    func clamped(to range: ClosedRange<Float>) -> Float {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - UIColor LAB Extension

extension UIColor {
    /// Get LAB color space components
    /// Note: This is an approximation using sRGB -> XYZ -> LAB conversion
    func getLAB(_ l: inout CGFloat, _ a: inout CGFloat, _ b: inout CGFloat, _ alpha: inout CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // sRGB to XYZ
        func pivotRgb(_ n: CGFloat) -> CGFloat {
            return n > 0.04045 ? pow((n + 0.055) / 1.055, 2.4) : n / 12.92
        }

        let r = pivotRgb(red) * 100
        let g = pivotRgb(green) * 100
        let bVal = pivotRgb(blue) * 100

        // Using D65 illuminant
        let x = r * 0.4124564 + g * 0.3575761 + bVal * 0.1804375
        let y = r * 0.2126729 + g * 0.7151522 + bVal * 0.0721750
        let z = r * 0.0193339 + g * 0.1191920 + bVal * 0.9503041

        // XYZ to LAB
        func pivotXyz(_ n: CGFloat) -> CGFloat {
            return n > 0.008856 ? pow(n, 1.0/3.0) : (7.787 * n) + (16.0/116.0)
        }

        // D65 reference white
        let refX: CGFloat = 95.047
        let refY: CGFloat = 100.000
        let refZ: CGFloat = 108.883

        let xPivot = pivotXyz(x / refX)
        let yPivot = pivotXyz(y / refY)
        let zPivot = pivotXyz(z / refZ)

        l = (116 * yPivot) - 16
        a = 500 * (xPivot - yPivot)
        b = 200 * (yPivot - zPivot)
    }

    /// Initialize from LAB color space components
    convenience init(l: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat) {
        // LAB to XYZ
        let y = (l + 16) / 116
        let x = a / 500 + y
        let z = y - b / 200

        func pivotXyz(_ n: CGFloat) -> CGFloat {
            let n3 = n * n * n
            return n3 > 0.008856 ? n3 : (n - 16.0/116.0) / 7.787
        }

        // D65 reference white
        let refX: CGFloat = 95.047
        let refY: CGFloat = 100.000
        let refZ: CGFloat = 108.883

        let xVal = pivotXyz(x) * refX / 100
        let yVal = pivotXyz(y) * refY / 100
        let zVal = pivotXyz(z) * refZ / 100

        // XYZ to sRGB
        var r = xVal *  3.2404542 + yVal * -1.5371385 + zVal * -0.4985314
        var g = xVal * -0.9692660 + yVal *  1.8760108 + zVal *  0.0415560
        var bVal2 = xVal *  0.0556434 + yVal * -0.2040259 + zVal *  1.0572252

        func pivotRgb(_ n: CGFloat) -> CGFloat {
            return n > 0.0031308 ? 1.055 * pow(n, 1/2.4) - 0.055 : 12.92 * n
        }

        r = pivotRgb(r).clamped(to: 0...1)
        g = pivotRgb(g).clamped(to: 0...1)
        bVal2 = pivotRgb(bVal2).clamped(to: 0...1)

        self.init(red: r, green: g, blue: bVal2, alpha: alpha)
    }
}
