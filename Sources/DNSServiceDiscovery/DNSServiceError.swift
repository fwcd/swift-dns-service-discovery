import CDNSSD

public enum DNSServiceError: Error, Hashable {
    case `internal`(Internal)
    case invalidServiceType
    case invalidDomain
    case invalidName
    case noServiceRef

    // Based on https://github.com/nallick/dns_sd/blob/9e9841c131cc1357fc63b69ff75d6d91e45b8429/Sources/dns_sd/Error.swift
    // MIT-licensed (Copyright (c) 2019 Purgatory Design)

    public enum Internal: CDNSSD.DNSServiceErrorType, Hashable {
        case noError = 0                 // kDNSServiceErr_NoError
        case unknown = -65537            // kDNSServiceErr_Unknown
        case noSuchName = -65538         // kDNSServiceErr_NoSuchName
        case noMemory = -65539           // kDNSServiceErr_NoMemory
        case badParam = -65540           // kDNSServiceErr_BadParam
        case badReference = -65541       // kDNSServiceErr_BadReference
        case badState = -65542           // kDNSServiceErr_BadState
        case badFlags = -65543           // kDNSServiceErr_BadFlags
        case unsupported = -65544        // kDNSServiceErr_Unsupported
        case notInitialized = -65545     // kDNSServiceErr_NotInitialized
        case alreadyRegistered = -65547  // kDNSServiceErr_AlreadyRegistered
        case nameConflict = -65548       // kDNSServiceErr_NameConflict
        case invalid = -65549            // kDNSServiceErr_Invalid
        case firewall = -65550           // kDNSServiceErr_Firewall
        case incompatible = -65551       // kDNSServiceErr_Incompatible
        case badInterfaceIndex = -65552  // kDNSServiceErr_BadInterfaceIndex
        case refused = -65553            // kDNSServiceErr_Refused
        case noSuchRecord = -65554       // kDNSServiceErr_NoSuchRecord
        case noAuth = -65555             // kDNSServiceErr_NoAuth
        case noSuchKey = -65556          // kDNSServiceErr_NoSuchKey
        case natTraversal = -65557       // kDNSServiceErr_NATTraversal
        case doubleNAT = -65558          // kDNSServiceErr_DoubleNAT
        case badTime = -65559            // kDNSServiceErr_BadTime
    }

    /// Wraps an erroring action in a high-level `DNSServiceError`.
    static func wrapInternal(action: () -> DNSServiceErrorType) throws {
        let rawError = action()
        let error = DNSServiceError.Internal(rawError)
        guard case .noError = error else {
            throw DNSServiceError.internal(error)
        }
    }
}

extension DNSServiceError.Internal {
    public init(_ errorCode: DNSServiceErrorType) {
        self = Self(rawValue: errorCode) ?? .unknown
    }
}
