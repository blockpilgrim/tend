//
//  ColorPalette.swift
//  Tend
//
//  Color utilities with interpolation helpers for Core state transitions.
//

import SwiftUI
import UIKit

enum ColorPalette {

    // MARK: - UI Colors

    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let accentPrimary = Color("AccentPrimary")
    static let accentSecondary = Color("AccentSecondary")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let success = Color("Success")
    static let neutral = Color("Neutral")

    // MARK: - Core Colors (Radiant)

    static let radiantInnerCore = Color("RadiantInnerCore")
    static let radiantInnerCoreBase = Color("RadiantInnerCoreBase")
    static let radiantGlow = Color("RadiantGlow")
    static let radiantSurface = Color("RadiantSurface")
    static let radiantStriation = Color("RadiantStriation")
    static let radiantHalo = Color("RadiantHalo")

    // MARK: - Core Colors (Dim)

    static let dimInnerCore = Color("DimInnerCore")
    static let dimInnerCoreBase = Color("DimInnerCoreBase")
    static let dimGlow = Color("DimGlow")
    static let dimSurface = Color("DimSurface")
    static let dimStriation = Color("DimStriation")
    static let dimHalo = Color("DimHalo")

    // MARK: - UIColor Versions (for SpriteKit)

    static let radiantInnerCoreUI = UIColor(named: "RadiantInnerCore")!
    static let radiantGlowUI = UIColor(named: "RadiantGlow")!
    static let radiantSurfaceUI = UIColor(named: "RadiantSurface")!
    static let radiantHaloUI = UIColor(named: "RadiantHalo")!

    static let dimInnerCoreUI = UIColor(named: "DimInnerCore")!
    static let dimGlowUI = UIColor(named: "DimGlow")!
    static let dimSurfaceUI = UIColor(named: "DimSurface")!

    // MARK: - Interpolation

    /// Interpolate inner core color based on adherence percentage
    static func interpolateInnerCore(adherence: CGFloat) -> UIColor {
        lerpColor(dimInnerCoreUI, radiantInnerCoreUI, adherence)
    }

    /// Interpolate glow color based on adherence percentage
    static func interpolateGlow(adherence: CGFloat) -> UIColor {
        lerpColor(dimGlowUI, radiantGlowUI, adherence)
    }

    /// Interpolate surface color based on adherence percentage
    static func interpolateSurface(adherence: CGFloat) -> UIColor {
        lerpColor(dimSurfaceUI, radiantSurfaceUI, adherence)
    }

    /// Get spark/ember color based on adherence percentage
    static func sparkColor(adherence: CGFloat) -> UIColor {
        if adherence > 0.7 {
            return UIColor(named: "RadiantStriation")!
        } else if adherence > 0.4 {
            return UIColor(named: "AccentSecondary")!
        } else {
            return UIColor(named: "DimStriation")!
        }
    }
}

// MARK: - Color Extension for Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8: // RGBA
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6:
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
