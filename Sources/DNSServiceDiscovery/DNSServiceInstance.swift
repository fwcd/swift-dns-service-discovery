/// A discovered service instance.
public struct DNSServiceInstance: Hashable {
    /// The instance name.
    public var name: String
    /// The service type.
    public var type: DNSServiceType
    /// The domain.
    public var domain: Domain
    /// The interface index on which the service was discovered.
    public var interfaceIndex: UInt32
    /// The IP address and port.
    public var addressInfo: AddressInfo? = nil
    /// The TXT record key-value pairs. Only provided during resolution.
    public var txtRecord: [String: String] = [:]
}
