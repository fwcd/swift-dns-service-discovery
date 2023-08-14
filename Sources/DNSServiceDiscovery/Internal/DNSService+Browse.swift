import CDNSSD

private typealias Identifier = UnsafeMutableRawPointer
private var browseCallbacks: [Identifier: (Result<DNSService.FoundInstance, Error>) -> Void] = [:]

extension DNSService {
    /// Starts browsing a service query. Note that either a call to `.setDispatchQueue` or
    /// repeated invocations of `.processResult` will be needed, otherwise the callback will
    /// never get called.
    static func browse(serviceType: DNSServiceType, domain: Domain, callback: @escaping (Result<FoundInstance, Error>) -> Void) throws -> DNSService {
        var serviceRef: CDNSSD.DNSServiceRef?
        let flags: Flags = []
        let interfaceIndex: UInt32 = 0
        let rawType = serviceType.rawValue
        let rawDomain = domain.rawValue

        let identifierBox = IdentifierBox {
            browseCallbacks[$0] = nil
        }
        browseCallbacks[identifierBox.wrappedIdentifier] = callback

        let callback: CDNSSD.DNSServiceBrowseReply = { (serviceRef, rawFlags, interfaceIndex, rawError, rawName, rawType, rawDomain, identifier) in
            guard let identifier,
                  let callback = browseCallbacks[identifier] else { return }

            callback(Result {
                try DNSServiceError.wrapInternal { rawError }

                guard let serviceType = rawType.flatMap(String.init(cString:)).map(DNSServiceType.init(rawValue:)) else { throw DNSServiceError.invalidServiceType }
                guard let domain = rawDomain.flatMap(String.init(cString:)).map(Domain.init(rawValue:)) else { throw DNSServiceError.invalidDomain }
                guard let name = rawName.flatMap(String.init(cString:)) else { throw DNSServiceError.invalidName }
                let flags = Flags(rawValue: rawFlags)

                let instance = DNSServiceInstance(name: name, type: serviceType, domain: domain, interfaceIndex: interfaceIndex)
                let foundInstance = FoundInstance(instance: instance, flags: flags)

                return foundInstance
            })
        }

        try DNSServiceError.wrapInternal {
            DNSServiceBrowse(&serviceRef, flags.rawValue, interfaceIndex, rawType, rawDomain, callback, identifierBox.wrappedIdentifier)
        }

        guard let serviceRef else {
            throw DNSServiceError.noServiceRef
        }

        return DNSService(identifierBox: identifierBox, wrappedRef: serviceRef)
    }
}
