/// A domain used for DNS-SD queries.
public struct Domain: RawRepresentable, ExpressibleByStringLiteral, Hashable, CustomStringConvertible {
    /// The root domain.
    public static let root: Self = "."
    /// The local domain used by mDNS.
    public static let local: Self = "local."

    public let rawValue: String

    public var relative: Self {
        rawValue.last == "." ? Self(rawValue: String(rawValue.dropLast())) : self
    }

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
