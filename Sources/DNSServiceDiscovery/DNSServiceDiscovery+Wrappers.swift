import CDNSSD

// MARK: Low-level implementations that wrap the C library.

private typealias Identifier = UnsafeMutableRawPointer
private var browseCallbacks: [Identifier: (Result<DNSServiceInstance, Error>) -> Void] = [:]

// TODO: Thread-safety

extension DNSServiceDiscovery {
    func browse(service: DNSServiceQuery, browseCallback: @escaping (Result<DNSServiceInstance, Error>) -> Void) {
        // TODO: `DNSServiceBrowse` seems to pass ownership to us and expect us to deallocate this.
        // We should therefore investigate which lifecycle these objects should have and where they
        // should be stored (e.g. in the DNSServiceDiscovery instance? Should we call this browse method
        // internally once when initializing the DNSServiceDiscovery object and then just pass the found
        // services immediately in lookup?)
        // Also, apparently browse sessions are supposed to run throughout the entire application,
        // we should probably read
        // - https://developer.apple.com/library/archive/documentation/Networking/Conceptual/dns_discovery_api/Articles/browse.html#//apple_ref/doc/uid/TP40002486-SW1
        // - https://marknelson.us/posts/2011/10/25/dns-service-discovery-on-windows.html
        // carefully.
        var reference: CDNSSD.DNSServiceRef?
        let flags: CDNSSD.DNSServiceFlags = 0
        let interfaceIndex: UInt32 = 0
        let rawType = service.type.rawValue
        let rawDomain = service.domain.rawValue

        let identifier = Identifier.allocate(byteCount: 0, alignment: 4)
        browseCallbacks[identifier] = browseCallback

        let callback: CDNSSD.DNSServiceBrowseReply = { (reference, flags, errorCode, interfaceIndex, rawName, rawType, rawDomain, identifier) in
            guard let identifier else { return }
            defer {
                browseCallbacks[identifier] = nil
                identifier.deallocate()
            }

            guard let browseCallback = browseCallbacks[identifier] else { return }

            guard errorCode == 0 else {
                browseCallback(.failure(BrowseError.asyncError(errorCode)))
                return
            }

            browseCallback(Result {
                guard let serviceType = rawType.flatMap(String.init(cString:)).map(DNSServiceType.init(rawValue:)) else { throw BrowseError.invalidServiceType }
                guard let domain = rawDomain.flatMap(String.init(cString:)).map(Domain.init(rawValue:)) else { throw BrowseError.invalidDomain }
                guard let name = rawName.flatMap(String.init(cString:)) else { throw BrowseError.invalidName }

                let query = DNSServiceQuery(type: serviceType, domain: domain)
                let instance = DNSServiceInstance(query: query, name: name)

                return instance
            })
        }

        let error = DNSServiceBrowse(&reference, flags, interfaceIndex, rawType, rawDomain, callback, identifier)
        guard error == kDNSServiceErr_NoError else {
            browseCallbacks[identifier] = nil
            identifier.deallocate()
            // TODO: Map kDNSServiceErr constants to high-level errors
            browseCallback(.failure(BrowseError.syncError(error)))
            return
        }
    }
}
