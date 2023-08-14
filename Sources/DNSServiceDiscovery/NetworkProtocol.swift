import CDNSSD

public enum NetworkProtocol: CDNSSD.DNSServiceProtocol, Hashable {
    case ipv4 = 0x01 // kDNSServiceProtocol_IPv4
    case ipv6 = 0x02 // kDNSServiceProtocol_IPv6
    case udp  = 0x10 // kDNSServiceProtocol_UDP
    case tcp  = 0x20 // kDNSServiceProtocol_TCP
}
