import Foundation

public enum IPAddress: Hashable {
    case ipv4(in_addr)
    case ipv6(in6_addr)

    // TODO: Provide `CustomStringConvertible`

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.ipv4(let l), .ipv4(let r)):
            return l.s_addr == r.s_addr
        case (.ipv6(let l), .ipv6(let r)):
            return l.__u6_addr.__u6_addr32 == r.__u6_addr.__u6_addr32
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .ipv4(let addr):
            addr.s_addr.hash(into: &hasher)
        case .ipv6(let addr):
            let (x0, x1, x2, x3) = addr.__u6_addr.__u6_addr32
            x0.hash(into: &hasher)
            x1.hash(into: &hasher)
            x2.hash(into: &hasher)
            x3.hash(into: &hasher)
        }
    }
}
