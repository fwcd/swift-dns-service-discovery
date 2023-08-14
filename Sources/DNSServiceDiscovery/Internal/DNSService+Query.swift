import CDNSSD

private typealias Identifier = UnsafeMutableRawPointer
private var browseCallbacks: [Identifier: (Result<DNSService.FoundInstance, Error>) -> Void] = [:]

extension DNSService {
    /// Browses or resolves the query. Note that either a call to `.setDispatchQueue` or
    /// repeated invocations of `.processResult` will be needed, otherwise the callback will
    /// never get called.
    static func query(_ query: DNSServiceQuery, callback: @escaping (Result<FoundInstance, Error>) -> Void) throws -> DNSService {
        if let name = query.name {
            return try resolve(name: name, serviceType: query.type, domain: query.domain, callback: callback)
        } else {
            return try browse(serviceType: query.type, domain: query.domain, callback: callback)
        }
    }
}
