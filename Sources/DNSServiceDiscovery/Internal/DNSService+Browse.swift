import CDNSSD

private typealias Identifier = UnsafeMutableRawPointer
private var browseCallbacks: [Identifier: (Result<DNSServiceInstance, Error>) -> Void] = [:]

extension DNSService {
    /// Starts browsing a service query. Note that either a call to `.setDispatchQueue` or
    /// repeated invocations of `.processResult` will be needed, otherwise the callback will
    /// never get called.
    static func browse(query: DNSServiceQuery, browseCallback: @escaping (Result<DNSServiceInstance, Error>) -> Void) throws -> DNSService {
        var serviceRef: CDNSSD.DNSServiceRef?
        let flags: CDNSSD.DNSServiceFlags = 0
        let interfaceIndex: UInt32 = 0
        let rawType = query.type.rawValue
        let rawDomain = query.domain.rawValue

        let identifierBox = IdentifierBox {
            browseCallbacks[$0] = nil
        }
        browseCallbacks[identifierBox.wrappedIdentifier] = browseCallback

        let callback: CDNSSD.DNSServiceBrowseReply = { (serviceRef, flags, interfaceIndex, rawError, rawName, rawType, rawDomain, identifier) in
            guard let identifier,
                  let browseCallback = browseCallbacks[identifier] else { return }

            browseCallback(Result {
                try DNSServiceError.wrapInternal { rawError }

                guard let serviceType = rawType.flatMap(String.init(cString:)).map(DNSServiceType.init(rawValue:)) else { throw DNSServiceError.invalidServiceType }
                guard let domain = rawDomain.flatMap(String.init(cString:)).map(Domain.init(rawValue:)) else { throw DNSServiceError.invalidDomain }
                guard let name = rawName.flatMap(String.init(cString:)) else { throw DNSServiceError.invalidName }

                let query = DNSServiceQuery(type: serviceType, domain: domain)
                let instance = DNSServiceInstance(query: query, name: name, interfaceIndex: interfaceIndex)

                return instance
            })
        }

        try DNSServiceError.wrapInternal {
            DNSServiceBrowse(&serviceRef, flags, interfaceIndex, rawType, rawDomain, callback, identifierBox.wrappedIdentifier)
        }

        guard let serviceRef else {
            throw DNSServiceError.noServiceRef
        }

        return DNSService(identifierBox: identifierBox, wrappedRef: serviceRef)
    }
}
