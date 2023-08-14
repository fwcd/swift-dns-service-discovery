import CDNSSD

private typealias Identifier = UnsafeMutableRawPointer

private struct ResolveQuery {
    let name: String
    let serviceType: DNSServiceType
    let domain: Domain
    let callback: (Result<DNSService.FoundInstance, Error>) -> Void
}

private var resolveQueries: [Identifier: ResolveQuery] = [:]

private func parse(rawTxtRecord: String) -> [String: String] {
    Dictionary(uniqueKeysWithValues: rawTxtRecord.split(separator: " ").map {
        let parsed = $0.split(separator: "=").map(String.init)
        return (parsed[0], parsed[1])
    })
}

extension DNSService {
    /// Resolves a service by name. Note that either a call to `.setDispatchQueue` or
    /// repeated invocations of `.processResult` will be needed, otherwise the callback will
    /// never get called.
    static func resolve(name: String, serviceType: DNSServiceType, domain: Domain, callback: @escaping (Result<FoundInstance, Error>) -> Void) throws -> DNSService {
        var serviceRef: CDNSSD.DNSServiceRef?
        let flags: Flags = []
        let interfaceIndex: UInt32 = 0
        let rawType = serviceType.rawValue
        let rawDomain = domain.rawValue

        let identifierBox = IdentifierBox {
            resolveQueries[$0] = nil
        }
        resolveQueries[identifierBox.wrappedIdentifier] = ResolveQuery(name: name, serviceType: serviceType, domain: domain, callback: callback)

        let callback: CDNSSD.DNSServiceResolveReply = { (serviceRef, rawFlags, interfaceIndex, rawError, rawName, rawHostTarget, port, txtLen, rawTxtRecord, identifier) in
            guard let identifier,
                  let resolveQuery = resolveQueries[identifier] else { return }

            resolveQuery.callback(Result {
                try DNSServiceError.wrapInternal { rawError }

                let flags = Flags(rawValue: rawFlags)
                let txtRecord = rawTxtRecord.map(String.init(cString:)).map(parse(rawTxtRecord:)) ?? [:]
                let instance = DNSServiceInstance(name: resolveQuery.name, type: resolveQuery.serviceType, domain: resolveQuery.domain, interfaceIndex: interfaceIndex, txtRecord: txtRecord)
                let foundInstance = FoundInstance(instance: instance, flags: flags)

                return foundInstance
            })
        }

        try DNSServiceError.wrapInternal {
            DNSServiceResolve(&serviceRef, flags.rawValue, interfaceIndex, name, rawType, rawDomain, callback, identifierBox.wrappedIdentifier)
        }

        guard let serviceRef else {
            throw DNSServiceError.noServiceRef
        }

        return DNSService(identifierBox: identifierBox, wrappedRef: serviceRef)
    }
}
