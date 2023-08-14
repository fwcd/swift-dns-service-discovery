public enum DNSServiceError: Error {
    case syncError(Int32)
    case asyncError(UInt32)
    case invalidServiceType
    case invalidDomain
    case invalidName
    case noServiceRef
}
