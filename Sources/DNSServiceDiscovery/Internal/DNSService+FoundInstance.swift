extension DNSService {
    /// A service instance with flags.
    struct FoundInstance {
        /// The found instance.
        let instance: DNSServiceInstance
        /// Internal flags set by the C library. The most interesting one is probably `.moreComing`.
        let flags: Flags

        func update(instances: inout [DNSServiceInstance]) {
            if flags.contains(.add) {
                instances.append(instance)
            } else {
                instances.removeAll { $0 == instance }
            }
        }
    }
}
