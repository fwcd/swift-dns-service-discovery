import CDNSSD
import Dispatch
import Foundation

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

    private var socketFd: Int32 {
        DNSServiceRefSockFD(wrappedRef)
    }

    init(identifierBox: IdentifierBox, wrappedRef: DNSServiceRef) {
        self.identifierBox = identifierBox
        self.wrappedRef = wrappedRef
    }

    deinit {
        DNSServiceRefDeallocate(wrappedRef)
    }

    /// Switches the socket to nonblocking mode.
    func setNonblocking() {
        let fd = socketFd
        var flags = fcntl(fd, F_GETFL, 0)
        if flags == -1 {
            flags = 0
        }
        _ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)
    }

    /// Schedules the browse callback to be received on the given dispatch queue.
    func setDispatchQueue(_ queue: DispatchQueue) throws {
        #if canImport(Darwin)
        try DNSServiceError.wrapInternal {
            DNSServiceSetDispatchQueue(wrappedRef, queue)
        }
        #else
        queue.async { [weak self] in
            // See https://github.com/nallick/dns_sd/blob/9e9841c131cc1357fc63b69ff75d6d91e45b8429/Sources/dns_sd/DNSService.swift#L146-L170
            // and https://stackoverflow.com/questions/7391079/avahi-dns-sd-compatibility-layer-fails-to-run-browse-callback

            self?.setNonblocking()

            while let self {
                var pfd = pollfd()
                pfd.fd = self.socketFd
                pfd.events = Int16(POLLIN)
                poll(&pfd, 1, -1)

                // TODO: Proper error-handling
                print("Processing result...")
                try! self.processResult()

                usleep(10000)
            }
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
