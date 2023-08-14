/// A domain used for DNS-SD queries.
public struct Domain: RawRepresentable, ExpressibleByStringLiteral, Hashable, CustomStringConvertible {
    /// The local domain used by mDNS.
    public static let local: Self = "local."

    public let rawValue: String

    public var description: String {
        rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
