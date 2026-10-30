import Foundation

/// Pure bundle-identifier matching for persistent app exclusions.
///
/// Bundle identifiers are compared case-insensitively and surrounding whitespace
/// is ignored. Preferences owns persistence; this kernel owns the normalization
/// rule so it can be tested without AppKit or UserDefaults.
public enum AppExclusionPolicy {
    public static func normalizedIdentifiers(_ identifiers: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for identifier in identifiers {
            let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let comparisonKey = trimmed.lowercased()
            guard seen.insert(comparisonKey).inserted else { continue }
            result.append(trimmed)
        }

        return result.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    public static func contains(_ bundleIdentifier: String?, in identifiers: [String]) -> Bool {
        guard let bundleIdentifier else { return false }
        let candidate = bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !candidate.isEmpty else { return false }

        return identifiers.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(candidate) == .orderedSame
        }
    }
}
