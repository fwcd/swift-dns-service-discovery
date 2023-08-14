import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

print("Resolving all AirPlay servers...")
sd.lookup(DNSServiceQuery(type: .airplay)) {
    let instances = try! $0.get()
    for instance in instances {
        sd.lookup(DNSServiceQuery(instance)) {
            let resolved = try! $0.get()[0]
            print("Resolved \(instance.name) (type: \(instance.type), domain: \(instance.domain)):")
            for (key, value) in resolved.txtRecord {
                print("  \(key): \(value.replacingOccurrences(of: "\n", with: "\\n"))")
            }
        }
    }
}

dispatchMain()
