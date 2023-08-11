import CDNSSD
import Dispatch
import ServiceDiscovery

public class DNSServiceDiscovery: ServiceDiscovery {
    public var defaultLookupTimeout: DispatchTimeInterval {
        // TODO
        .seconds(16)
    }

    public init() {

    }

    public func lookup(
        _ service: DNSService,
        deadline: DispatchTime? = nil,
        callback: @escaping (Result<[DNSInstance], Error>) -> Void
    ) {
        // TODO: Use the deadline
        let deadline = deadline ?? .now() + defaultLookupTimeout

        // TODO: Browse until deadline for multiple services
        // TODO: Why doesn't the callback get called?

        browse(service: service) { instance in
            callback(Result { [try instance.get()] })
        }
    }

    public func subscribe(
        to service: DNSService,
        onNext nextResultHandler: @escaping (Result<[DNSInstance], Error>) -> Void,
        onComplete completionHandler: @escaping (CompletionReason) -> Void
    ) -> CancellationToken {
        // TODO
        return .init()
    }
}

// MARK: Custom error types

extension DNSServiceDiscovery {
    public enum BrowseError: Error {
        case syncError(Int32)
        case asyncError(UInt32)
        case invalidServiceType
        case invalidDomain
        case invalidName
    }
}

// MARK: Low-level implementations that wrap the C library.

private typealias Identifier = UnsafeMutableRawPointer
private var browseCallbacks: [Identifier: (Result<DNSInstance, Error>) -> Void] = [:]

// TODO: Thread-safety

extension DNSServiceDiscovery {
    private func browse(service: DNSService, browseCallback: @escaping (Result<DNSInstance, Error>) -> Void) {
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
                guard let serviceType = rawType.flatMap(String.init(cString:)).map(DNSService.ServiceType.init(rawValue:)) else { throw BrowseError.invalidServiceType }
                guard let domain = rawDomain.flatMap(String.init(cString:)).map(DNSService.Domain.init(rawValue:)) else { throw BrowseError.invalidDomain }
                guard let name = rawName.flatMap(String.init(cString:)) else { throw BrowseError.invalidName }

                let service = DNSService(type: serviceType, domain: domain)
                let instance = DNSInstance(service: service, name: name)

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
