/// A discovered service instance.
public struct DNSServiceInstance: Hashable {
    /// The service type and domain.
    public var query: DNSServiceQuery
    /// The instance name.
    public var name: String
    /// The interface index on which the service was discovered.
    public var interfaceIndex: UInt32
}
