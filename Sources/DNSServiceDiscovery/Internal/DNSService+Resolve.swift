import CDNSSD

private typealias Identifier = UnsafeMutableRawPointer

private struct ResolveQuery {
    let name: String
    let serviceType: DNSServiceType
    let domain: Domain
    let callback: (Result<DNSService.FoundInstance, Error>) -> Void
}

private var resolveQueries: [Identifier: ResolveQuery] = [:]

private func readCString(from pointer: UnsafePointer<UInt8>, in range: Range<Int>) -> String {
    var chars: [UInt8] = []
    for i in range {
        chars.append(pointer[i])
    }
    chars.append(0)
    return String(cString: chars)
}

private func parse(rawTxtRecord: UnsafePointer<UInt8>, txtLen: Int) -> [String: String] {
    var txtRecord: [String: String] = [:]
    var i = 0
    while i < txtLen {
        let length = Int(rawTxtRecord[i])
        i += 1
        let rawPair = readCString(from: rawTxtRecord, in: i..<(i + length))
        let parsedPair = rawPair.split(separator: "=").map(String.init)
        if parsedPair.count >= 2 {
            txtRecord[parsedPair[0]] = parsedPair[1]
        }
        i += length
    }
    return txtRecord
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

                var flags = Flags(rawValue: rawFlags)
                flags.insert(.add) // We always consider resolved instances "added" so we can deal with them in a uniform way on a higher level

                let txtRecord = rawTxtRecord.map { parse(rawTxtRecord: $0, txtLen: Int(txtLen)) } ?? [:]
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
