/// A discovered service instance.
public struct DNSServiceInstance: Hashable {
    /// The service type and domain.
    public var query: DNSServiceQuery
    /// The instance name.
    public var name: String
}
