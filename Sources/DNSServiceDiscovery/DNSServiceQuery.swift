/// A structured representation of a DNS-SD-style domain for querying,
/// e.g. `_services._dns-sd._udp.<domain>`.
public struct DNSServiceQuery: Hashable, CustomStringConvertible {
    public var type: DNSServiceType
    public var domain: Domain

    /// The DNS-SD-style domain.
    public var description: String {
        "\(type).\(domain)"
    }

    public init(type: DNSServiceType, domain: Domain = .local) {
        self.type = type
        self.domain = domain
    }
}
