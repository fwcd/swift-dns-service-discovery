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

        func finish(with result: Result<[DNSServiceInstance], Error>) {
            activeServices[uuid] = nil
            callback(result)
        }

        queue.asyncAfter(deadline: deadline) { [self] in
            if activeServices[uuid] != nil {
                finish(with: .success(instances))
            }
        }

        do {
            let service = try DNSService.browse(serviceType: query.type, domain: query.domain) { [unowned self] in
                guard activeServices[uuid] != nil else { return }
                do {
                    let browseInstance = try $0.get()
                    browseInstance.update(instances: &instances)
                    if !browseInstance.flags.contains(.moreComing) {
                        finish(with: .success(instances))
                    }
                } catch {
                    finish(with: .failure(error))
                }
            }

            try service.setDispatchQueue(queue)
            activeServices[uuid] = service
        } catch {
            finish(with: .failure(error))
        }
    }

    public func subscribe(
        to query: DNSServiceQuery,
        onNext nextResultHandler: @escaping (Result<[DNSServiceInstance], Error>) -> Void,
        onComplete completionHandler: @escaping (CompletionReason) -> Void
    ) -> CancellationToken {
        let uuid = UUID()
        var instances: [DNSServiceInstance] = []

        func finish(with reason: CompletionReason) {
            activeServices[uuid] = nil
            completionHandler(reason)
        }

        do {
            let service = try DNSService.browse(serviceType: query.type, domain: query.domain) { [unowned self] in
                guard activeServices[uuid] != nil else { return }
                do {
                    let foundInstance = try $0.get()
                    foundInstance.update(instances: &instances)
                    if !foundInstance.flags.contains(.moreComing) {
                        nextResultHandler(.success(instances))
                    }
                } catch {
                    nextResultHandler(.failure(error))
                }
            }

            try service.setDispatchQueue(queue)
            activeServices[uuid] = service

            return CancellationToken(completionHandler: finish(with:))
        } catch {
            // TODO: Log error
            finish(with: .serviceDiscoveryUnavailable)

            return CancellationToken { _ in }
        }
    }
}

// MARK: Custom error types


