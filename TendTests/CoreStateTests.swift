//
//  CoreStateTests.swift
//  TendTests
//
//  Unit tests for CoreState and CoreTier - validates state
//  representation and tier boundary calculations.
//

import XCTest
@testable import Tend

final class CoreStateTests: XCTestCase {

    // MARK: - Tier Calculation Tests

    func testTier_BlazingRange_90To100() {
        XCTAssertEqual(CoreState(adherencePercentage: 1.0).tier, .blazing)
        XCTAssertEqual(CoreState(adherencePercentage: 0.95).tier, .blazing)
        XCTAssertEqual(CoreState(adherencePercentage: 0.90).tier, .blazing)
    }

    func testTier_WarmRange_70To89() {
        XCTAssertEqual(CoreState(adherencePercentage: 0.899).tier, .warm)
        XCTAssertEqual(CoreState(adherencePercentage: 0.80).tier, .warm)
        XCTAssertEqual(CoreState(adherencePercentage: 0.70).tier, .warm)
    }

    func testTier_SmolderingRange_50To69() {
        XCTAssertEqual(CoreState(adherencePercentage: 0.699).tier, .smoldering)
        XCTAssertEqual(CoreState(adherencePercentage: 0.60).tier, .smoldering)
        XCTAssertEqual(CoreState(adherencePercentage: 0.50).tier, .smoldering)
    }

    func testTier_DimRange_30To49() {
        XCTAssertEqual(CoreState(adherencePercentage: 0.499).tier, .dim)
        XCTAssertEqual(CoreState(adherencePercentage: 0.40).tier, .dim)
        XCTAssertEqual(CoreState(adherencePercentage: 0.30).tier, .dim)
    }

    func testTier_ColdRange_0To29() {
        XCTAssertEqual(CoreState(adherencePercentage: 0.299).tier, .cold)
        XCTAssertEqual(CoreState(adherencePercentage: 0.15).tier, .cold)
        XCTAssertEqual(CoreState(adherencePercentage: 0.0).tier, .cold)
    }

    // MARK: - Preset States Tests

    func testPresetNeutral_Is50Percent() {
        XCTAssertEqual(CoreState.neutral.adherencePercentage, 0.5)
        XCTAssertEqual(CoreState.neutral.tier, .smoldering)
    }

    func testPresetRadiant_Is100Percent() {
        XCTAssertEqual(CoreState.radiant.adherencePercentage, 1.0)
        XCTAssertEqual(CoreState.radiant.tier, .blazing)
    }

    func testPresetDim_Is0Percent() {
        XCTAssertEqual(CoreState.dim.adherencePercentage, 0.0)
        XCTAssertEqual(CoreState.dim.tier, .cold)
    }

    // MARK: - Equatable Tests

    func testEquatable_SamePercentage_AreEqual() {
        let state1 = CoreState(adherencePercentage: 0.75)
        let state2 = CoreState(adherencePercentage: 0.75)
        XCTAssertEqual(state1, state2)
    }

    func testEquatable_DifferentPercentage_AreNotEqual() {
        let state1 = CoreState(adherencePercentage: 0.75)
        let state2 = CoreState(adherencePercentage: 0.76)
        XCTAssertNotEqual(state1, state2)
    }

    // MARK: - CoreTier Description Tests

    func testCoreTierDescription_AllTiers() {
        XCTAssertEqual(CoreTier.blazing.description, "Blazing")
        XCTAssertEqual(CoreTier.warm.description, "Warm")
        XCTAssertEqual(CoreTier.smoldering.description, "Smoldering")
        XCTAssertEqual(CoreTier.dim.description, "Dim")
        XCTAssertEqual(CoreTier.cold.description, "Cold")
    }

    func testCoreTierAllCases_ContainsAllFiveTiers() {
        XCTAssertEqual(CoreTier.allCases.count, 5)
        XCTAssertTrue(CoreTier.allCases.contains(.blazing))
        XCTAssertTrue(CoreTier.allCases.contains(.warm))
        XCTAssertTrue(CoreTier.allCases.contains(.smoldering))
        XCTAssertTrue(CoreTier.allCases.contains(.dim))
        XCTAssertTrue(CoreTier.allCases.contains(.cold))
    }

    // MARK: - Edge Cases

    func testAdherencePercentage_ExactBoundaries() {
        // Test exact boundary values
        XCTAssertEqual(CoreState(adherencePercentage: 0.9).tier, .blazing, "90% exactly should be Blazing")
        XCTAssertEqual(CoreState(adherencePercentage: 0.7).tier, .warm, "70% exactly should be Warm")
        XCTAssertEqual(CoreState(adherencePercentage: 0.5).tier, .smoldering, "50% exactly should be Smoldering")
        XCTAssertEqual(CoreState(adherencePercentage: 0.3).tier, .dim, "30% exactly should be Dim")
    }

    func testAdherencePercentage_JustBelowBoundaries() {
        // Test values just below boundaries
        XCTAssertEqual(CoreState(adherencePercentage: 0.8999).tier, .warm, "89.99% should be Warm")
        XCTAssertEqual(CoreState(adherencePercentage: 0.6999).tier, .smoldering, "69.99% should be Smoldering")
        XCTAssertEqual(CoreState(adherencePercentage: 0.4999).tier, .dim, "49.99% should be Dim")
        XCTAssertEqual(CoreState(adherencePercentage: 0.2999).tier, .cold, "29.99% should be Cold")
    }

    func testAdherencePercentage_NegativeValue_IsCold() {
        // Although invalid, negative values should be handled gracefully
        let state = CoreState(adherencePercentage: -0.1)
        XCTAssertEqual(state.tier, .cold)
    }

    func testAdherencePercentage_GreaterThan100_FallsToDefault() {
        // Values >1.0 fall outside the 0.9...1.0 range, so they go to default (cold)
        // This is acceptable since >100% is invalid input anyway
        let state = CoreState(adherencePercentage: 1.5)
        // Implementation uses closed range 0.9...1.0, so >1.0 falls to default
        XCTAssertEqual(state.tier, .cold)
    }
}
