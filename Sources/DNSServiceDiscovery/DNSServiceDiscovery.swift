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
        _ service: DNSServiceQuery,
        deadline: DispatchTime? = nil,
        callback: @escaping (Result<[DNSServiceInstance], Error>) -> Void
    ) {
        // TODO: Use the deadline
        let deadline = deadline ?? .now() + defaultLookupTimeout

        // TODO: Browse until deadline for multiple services
        // TODO: Why doesn't the callback get called?
        // TODO: Read this doc in detail: https://developer.apple.com/library/archive/documentation/Networking/Conceptual/dns_discovery_api/Introduction.html

        browse(service: service) { instance in
            callback(Result { [try instance.get()] })
        }
    }

    public func subscribe(
        to service: DNSServiceQuery,
        onNext nextResultHandler: @escaping (Result<[DNSServiceInstance], Error>) -> Void,
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
