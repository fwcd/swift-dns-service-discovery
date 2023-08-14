#if canImport(Darwin)

import CDNSSD

private typealias Identifier = UnsafeMutableRawPointer

private var getAddrInfoCallbacks: [Identifier: (Result<AddressInfo, Error>) -> Void] = [:]

extension DNSService {
    /// Fetches the address info for a service.
    static func getAddrInfo(name: String, domain: Domain, protocol: NetworkProtocol, callback: @escaping (Result<AddressInfo, Error>) -> Void) throws -> DNSService {
        var serviceRef: CDNSSD.DNSServiceRef?
        let fqName = "\(name).\(domain)"
        let flags: Flags = []
        let interfaceIndex: UInt32 = 0

        let identifierBox = IdentifierBox {
            getAddrInfoCallbacks[$0] = nil
        }
        getAddrInfoCallbacks[identifierBox.wrappedIdentifier] = callback

        let callback: CDNSSD.DNSServiceGetAddrInfoReply = { (serviceRef, rawFlags, interfaceIndex, rawError, rawName, rawAddrPtr, ttl, identifier) in
            guard let identifier,
                  let callback = getAddrInfoCallbacks[identifier] else { return }

            callback(Result {
                try DNSServiceError.wrapInternal { rawError }

                guard let rawAddrPtr else { throw DNSServiceError.noAddress }
                let rawFamily = rawAddrPtr.pointee.sa_family

                switch rawFamily {
                case UInt8(AF_INET):
                    let inPtr = UnsafeRawPointer(rawAddrPtr).assumingMemoryBound(to: sockaddr_in.self)
                    let ipAddress = inPtr.pointee.sin_addr
                    let port = inPtr.pointee.sin_port
                    return AddressInfo(ipAddress: .ipv4(ipAddress), port: port)
                case UInt8(AF_INET6):
                    let inPtr = UnsafeRawPointer(rawAddrPtr).assumingMemoryBound(to: sockaddr_in6.self)
                    let ipAddress = inPtr.pointee.sin6_addr
                    let port = inPtr.pointee.sin6_port
                    return AddressInfo(ipAddress: .ipv6(ipAddress), port: port)
                default:
                    throw DNSServiceError.invalidAddressFamily(rawFamily)
                }
            })
        }

        try DNSServiceError.wrapInternal {
            DNSServiceGetAddrInfo(&serviceRef, flags.rawValue, interfaceIndex, `protocol`.rawValue, fqName, callback, identifierBox.wrappedIdentifier)
        }

        guard let serviceRef else {
            throw DNSServiceError.noServiceRef
        }

        return DNSService(identifierBox: identifierBox, wrappedRef: serviceRef)
    }
}

#endif
