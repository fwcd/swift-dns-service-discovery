/// A structured representation of a DNS-SD-style domain for querying,
/// e.g. `_services._dns-sd._udp.<domain>`.
public struct DNSServiceQuery: Hashable {
    public var name: String?
    public var type: DNSServiceType
    public var domain: Domain

    public init(name: String? = nil, type: DNSServiceType, domain: Domain = .local) {
        self.name = name
        self.type = type
        self.domain = domain
    }
}
