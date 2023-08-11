/// A structured representation of a DNS-SD-style domain for querying,
/// e.g. `_services._dns-sd._udp.<domain>`.
public struct DNSService: Hashable, CustomStringConvertible {
    public var type: ServiceType
    public var domain: Domain

    /// The DNS-SD-style domain.
    public var description: String {
        "\(type).\(domain)"
    }

    public init(type: ServiceType, domain: Domain = .local) {
        self.type = type
        self.domain = domain
    }

    /// A DNS-SD service types.
    /// 
    /// A list of available services can be found here:
    /// - http://www.dns-sd.org/servicetypes.html
    /// - https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml
    public struct ServiceType: RawRepresentable, ExpressibleByStringLiteral, Hashable, CustomStringConvertible {
        /// A DNS-service whose instances resolve to available DNS-SD service types.
        public static let dnsSdServices: Self = "_services._dns-sd._udp"

        // TODO: Add more service types, perhaps even auto-generate them via a macro or script?

        /// AirPlay 2 servers.
        public static let airplay: Self = "_airplay._tcp"
        /// iTunes/Apple Music Home Sharing, i.e. Digital Audio Access Protocol (DAAP) servers.
        public static let homeSharing: Self = "_home-sharing._tcp"
        /// Hypertext Transfer Protocol (HTTP) servers.
        public static let http: Self = "_http._tcp"
        /// AirPlay 1 audio (AirTunes) servers.
        public static let raop: Self = "_raop._tcp"
        /// Secure File Transfer Protocol (SFTP) over SSH servers.
        public static let sftpSsh: Self = "_sftp-ssh._tcp"
        /// Secure Shell (SSH) servers.
        public static let ssh: Self = "_ssh._tcp"
        /// Server Message Block over TCP/IP servers.
        public static let smb: Self = "_smb._tcp"

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

    /// A domain used for DNS-SD queries.
    public struct Domain: RawRepresentable, ExpressibleByStringLiteral, Hashable, CustomStringConvertible {
        /// The local domain used by mDNS.
        public static let local: Self = "local"

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
}
