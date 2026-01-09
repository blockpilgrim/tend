//
//  RevenueCatService.swift
//  Tend
//
//  RevenueCat integration for subscription management.
//  Configuration will be completed in the Premium epic.
//

import Foundation
import RevenueCat

/// Service for managing premium subscriptions via RevenueCat.
///
/// ## Setup Required
/// 1. Add RevenueCat SPM package: https://github.com/RevenueCat/purchases-ios-spm
/// 2. Configure with API key in TendApp.swift
/// 3. Set up products in App Store Connect and RevenueCat dashboard
final class RevenueCatService {

    static let shared = RevenueCatService()

    private init() {}

    // MARK: - Configuration

    /// Configure RevenueCat with API key
    /// Call this in TendApp.init()
    func configure() {
        // TODO: Implement when RevenueCat is configured
        // Purchases.logLevel = .debug  // Remove in production
        // Purchases.configure(withAPIKey: "your_revenuecat_api_key")
        print("[RevenueCat] Configuration placeholder - API key not yet set")
    }

    // MARK: - Entitlements

    /// Check if user has premium access
    func checkPremiumStatus() async -> Bool {
        // TODO: Implement when RevenueCat is configured
        // do {
        //     let customerInfo = try await Purchases.shared.customerInfo()
        //     return customerInfo.entitlements["premium"]?.isActive == true
        // } catch {
        //     return false
        // }
        return false
    }

    // MARK: - Offerings

    /// Fetch available subscription offerings
    func fetchOfferings() async throws -> [SubscriptionOffering] {
        // TODO: Implement when RevenueCat is configured
        // let offerings = try await Purchases.shared.offerings()
        // return offerings.current?.availablePackages.map { ... } ?? []
        return []
    }

    // MARK: - Purchases

    /// Purchase a subscription package
    func purchase(offeringId: String) async throws -> Bool {
        // TODO: Implement when RevenueCat is configured
        // let offerings = try await Purchases.shared.offerings()
        // guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == offeringId }) else {
        //     throw RevenueCatError.offeringNotFound
        // }
        // let result = try await Purchases.shared.purchase(package: package)
        // return result.customerInfo.entitlements["premium"]?.isActive == true
        return false
    }

    // MARK: - Restore

    /// Restore previous purchases
    func restorePurchases() async throws -> Bool {
        // TODO: Implement when RevenueCat is configured
        // let customerInfo = try await Purchases.shared.restorePurchases()
        // return customerInfo.entitlements["premium"]?.isActive == true
        return false
    }
}

// MARK: - Supporting Types

/// Represents a subscription offering for display
struct SubscriptionOffering: Identifiable {
    let id: String
    let title: String
    let description: String
    let priceString: String
    let periodString: String
}

/// Errors that can occur during RevenueCat operations
enum RevenueCatError: Error, LocalizedError {
    case notConfigured
    case offeringNotFound
    case purchaseFailed(underlying: Error)
    case restoreFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "RevenueCat is not configured"
        case .offeringNotFound:
            return "Subscription offering not found"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .restoreFailed(let error):
            return "Restore failed: \(error.localizedDescription)"
        }
    }
}
