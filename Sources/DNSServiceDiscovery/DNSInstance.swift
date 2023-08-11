/// A discovered service instance.
public struct DNSInstance: Hashable {
    /// The service type and domain.
    public var service: DNSService
    /// The instance name.
    public var name: String
}
