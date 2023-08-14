import CDNSSD
import Dispatch

// TODO: Thread-safety

/// A low-level, owned wrapper around a `DNSServiceRef` (which internally manages a connection to the mDNSResponder daemon).
final class DNSService {
    typealias Identifier = UnsafeMutableRawPointer

    /// An owned wrapper around an identifier that automatically performs cleanup.
    class IdentifierBox {
        let wrappedIdentifier = Identifier.allocate(byteCount: 0, alignment: 0)
        let onDeinit: (Identifier) -> Void

        init(onDeinit: @escaping (Identifier) -> Void) {
            self.onDeinit = onDeinit
        }

        deinit {
            onDeinit(wrappedIdentifier)
            wrappedIdentifier.deallocate()
        }
    }

    private let identifierBox: IdentifierBox
    private let wrappedRef: DNSServiceRef

    init(identifierBox: IdentifierBox, wrappedRef: DNSServiceRef) {
        self.identifierBox = identifierBox
        self.wrappedRef = wrappedRef
    }

    deinit {
        DNSServiceRefDeallocate(wrappedRef)
    }

    /// Schedules the browse callback to be received on the given dispatch queue.
    func setDispatchQueue(_ queue: DispatchQueue) throws {
        #if canImport(Darwin)
        try DNSServiceError.wrapInternal {
            DNSServiceSetDispatchQueue(wrappedRef, queue)
        }
        #else
        queue.async {
            // FIXME: Implement this, see https://github.com/fwcd/swift-dns-service-discovery/issues/1
            fatalError("DNSService.setDispatchQueue is not implemented on non-Darwin-platforms yet!")
        }
        #endif
    }

    /// Manually pumps an event by reading a reply from the daemon.
    func processResult() throws {
        try DNSServiceError.wrapInternal {
            DNSServiceProcessResult(wrappedRef)
        }
    }
}
