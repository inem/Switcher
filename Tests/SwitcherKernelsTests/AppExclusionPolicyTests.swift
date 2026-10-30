import SwitcherKernels

enum AppExclusionPolicyTests {
    static func runAll() {
        Check.run("testExcludedBundleIdentifierMatches", testExcludedBundleIdentifierMatches)
        Check.run("testMatchingIgnoresCaseAndWhitespace", testMatchingIgnoresCaseAndWhitespace)
        Check.run("testMissingBundleIdentifierIsNotExcluded", testMissingBundleIdentifierIsNotExcluded)
        Check.run("testNormalizationDropsEmptyAndDuplicateIdentifiers",
                  testNormalizationDropsEmptyAndDuplicateIdentifiers)
    }

    static func testExcludedBundleIdentifierMatches() {
        Check.expect(AppExclusionPolicy.contains("com.apple.mail", in: ["com.apple.mail"]))
        Check.expect(!AppExclusionPolicy.contains("com.apple.Safari", in: ["com.apple.mail"]))
    }

    static func testMatchingIgnoresCaseAndWhitespace() {
        Check.expect(AppExclusionPolicy.contains("COM.APPLE.MAIL", in: ["  com.apple.mail\n"]))
    }

    static func testMissingBundleIdentifierIsNotExcluded() {
        Check.expect(!AppExclusionPolicy.contains(nil, in: ["com.apple.mail"]))
        Check.expect(!AppExclusionPolicy.contains("   ", in: ["com.apple.mail"]))
    }

    static func testNormalizationDropsEmptyAndDuplicateIdentifiers() {
        Check.equal(
            AppExclusionPolicy.normalizedIdentifiers([
                " com.apple.Safari ",
                "com.apple.mail",
                "COM.APPLE.MAIL",
                "",
                "  ",
            ]),
            ["com.apple.mail", "com.apple.Safari"]
        )
    }
}
