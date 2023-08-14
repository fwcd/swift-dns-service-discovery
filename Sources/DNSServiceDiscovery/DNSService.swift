import CDNSSD
import Dispatch

private typealias Identifier = UnsafeMutableRawPointer
private var browseCallbacks: [Identifier: (Result<DNSServiceInstance, Error>) -> Void] = [:]

// TODO: Thread-safety

/// An owned wrapper around an identifier that automatically performs cleanup.
private class IdentifierBox {
    var wrappedIdentifier = Identifier.allocate(byteCount: 0, alignment: 0)

    deinit {
        browseCallbacks[wrappedIdentifier] = nil
        wrappedIdentifier.deallocate()
    }
}

/// A low-level, owned wrapper around a `DNSServiceRef` (which internally manages a connection to the mDNSResponder daemon).
final class DNSService {
    private let identifierBox: IdentifierBox
    private let wrappedRef: DNSServiceRef

    private init(identifierBox: IdentifierBox, wrappedRef: DNSServiceRef) {
        self.identifierBox = identifierBox
        self.wrappedRef = wrappedRef
    }

    deinit {
        DNSServiceRefDeallocate(wrappedRef)
    }

    static func browse(query: DNSServiceQuery, browseCallback: @escaping (Result<DNSServiceInstance, Error>) -> Void) throws -> DNSService {
        var serviceRef: CDNSSD.DNSServiceRef?
        let flags: CDNSSD.DNSServiceFlags = 0
        let interfaceIndex: UInt32 = 0
        let rawType = query.type.rawValue
        let rawDomain = query.domain.rawValue

        let identifierBox = IdentifierBox()
        browseCallbacks[identifierBox.wrappedIdentifier] = browseCallback

        let callback: CDNSSD.DNSServiceBrowseReply = { (serviceRef, flags, errorCode, interfaceIndex, rawName, rawType, rawDomain, identifier) in
            guard let identifier,
                  let browseCallback = browseCallbacks[identifier] else { return }

            guard errorCode == 0 else {
                browseCallback(.failure(DNSServiceError.asyncError(errorCode)))
                return
            }

            browseCallback(Result {
                guard let serviceType = rawType.flatMap(String.init(cString:)).map(DNSServiceType.init(rawValue:)) else { throw DNSServiceError.invalidServiceType }
                guard let domain = rawDomain.flatMap(String.init(cString:)).map(Domain.init(rawValue:)) else { throw DNSServiceError.invalidDomain }
                guard let name = rawName.flatMap(String.init(cString:)) else { throw DNSServiceError.invalidName }

                let query = DNSServiceQuery(type: serviceType, domain: domain)
                let instance = DNSServiceInstance(query: query, name: name, interfaceIndex: interfaceIndex)

                return instance
            })
        }

        let error = DNSServiceBrowse(&serviceRef, flags, interfaceIndex, rawType, rawDomain, callback, identifierBox.wrappedIdentifier)
        guard error == kDNSServiceErr_NoError else {
            // TODO: Map kDNSServiceErr constants to high-level errors
            throw DNSServiceError.syncError(error)
        }

        guard let serviceRef else {
            throw DNSServiceError.noServiceRef
        }

        return DNSService(identifierBox: identifierBox, wrappedRef: serviceRef)
    }

    func setDispatchQueue(_ queue: DispatchQueue) {
        DNSServiceSetDispatchQueue(wrappedRef, queue)
    }
}
