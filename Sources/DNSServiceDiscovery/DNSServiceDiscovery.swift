import Dispatch
import ServiceDiscovery

public class DNSServiceDiscovery: ServiceDiscovery {
    public var defaultLookupTimeout: DispatchTimeInterval {
        // TODO
        .seconds(16)
    }

    public func lookup(
        _ service: DNSService,
        deadline: DispatchTime?,
        callback: @escaping (Result<[DNSInstance], Error>) -> Void
    ) {
        // TODO
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
