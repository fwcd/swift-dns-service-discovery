/// A DNS-SD service type.
/// 
/// A list of available services can be found here:
/// - http://www.dns-sd.org/servicetypes.html
/// - https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml
public struct DNSServiceType: RawRepresentable, ExpressibleByStringLiteral, Hashable, CustomStringConvertible {
    /// A DNS-service whose instances resolve to available DNS-SD service types.
    public static let dnsSdServices: Self = "_services._dns-sd._udp"

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
