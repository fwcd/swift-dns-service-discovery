import Foundation

// TODO: Provide a higher-level wrapper around IP addresses

public enum IPAddress {
    case ipv4(in_addr)
    case ipv6(in6_addr)
}
