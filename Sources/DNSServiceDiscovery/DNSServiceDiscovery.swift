import Dispatch
import ServiceDiscovery

/// A facility for performing discovery of DNS service instances.
/// Callbacks will be scheduled on an internal queue.
public class DNSServiceDiscovery: ServiceDiscovery {
    /// The queue on which callbacks will be scheduled.
    private let queue = DispatchQueue(label: "DNSServiceDiscovery")

    public var defaultLookupTimeout: DispatchTimeInterval {
        // TODO
        .seconds(16)
    }

    public init() {

    }

    public func lookup(
        _ query: DNSServiceQuery,
        deadline: DispatchTime? = nil,
        callback: @escaping (Result<[DNSServiceInstance], Error>) -> Void
    ) {
        // TODO: Use the deadline
        let deadline = deadline ?? .now() + defaultLookupTimeout

        // TODO: Browse until deadline for multiple services
        // TODO: Why doesn't the callback get called?
        // TODO: Read this doc in detail: https://developer.apple.com/library/archive/documentation/Networking/Conceptual/dns_discovery_api/Introduction.html

        do {
            let service = try DNSService.browse(query: query) { instance in
                callback(Result { [try instance.get()] })
            }

            try service.setDispatchQueue(queue)
        } catch {
            callback(.failure(error))
        }
    }

    public func subscribe(
        to query: DNSServiceQuery,
        onNext nextResultHandler: @escaping (Result<[DNSServiceInstance], Error>) -> Void,
        onComplete completionHandler: @escaping (CompletionReason) -> Void
    ) -> CancellationToken {
        // TODO
        return .init()
    }
}

// MARK: Custom error types


