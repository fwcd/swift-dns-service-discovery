import Dispatch
import Foundation
import ServiceDiscovery

/// A facility for performing discovery of DNS service instances.
/// Callbacks will be scheduled on an internal queue.
public class DNSServiceDiscovery: ServiceDiscovery {
    /// The queue on which callbacks will be scheduled.
    private let queue: DispatchQueue
    /// Services that are actively being queried.
    private var activeServices: [UUID: DNSService] = [:]

    public var defaultLookupTimeout: DispatchTimeInterval {
        .seconds(4)
    }

    public init(queue: DispatchQueue = DispatchQueue(label: "DNSServiceDiscovery")) {
        self.queue = queue
    }

    public func lookup(
        _ query: DNSServiceQuery,
        deadline: DispatchTime? = nil,
        callback: @escaping (Result<[DNSServiceInstance], Error>) -> Void
    ) {
        let deadline = deadline ?? .now() + defaultLookupTimeout
        let uuid = UUID()
        var instances: [DNSServiceInstance] = []

        func finishWithCallback(_ result: Result<[DNSServiceInstance], Error>) {
            activeServices[uuid] = nil
            callback(result)
        }

        queue.asyncAfter(deadline: deadline) { [self] in
            if activeServices[uuid] != nil {
                finishWithCallback(.success(instances))
            }
        }

        do {
            let service = try DNSService.browse(query: query) { [unowned self] in
                guard activeServices[uuid] != nil else { return }
                do {
                    let browseInstance = try $0.get()
                    if browseInstance.flags.contains(.moreComing) {
                        instances.append(browseInstance.instance)
                    } else {
                        finishWithCallback(.success(instances))
                    }
                } catch {
                    finishWithCallback(.failure(error))
                }
            }

            try service.setDispatchQueue(queue)
            activeServices[uuid] = service
        } catch {
            finishWithCallback(.failure(error))
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


