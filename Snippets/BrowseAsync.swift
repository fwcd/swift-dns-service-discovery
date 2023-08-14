import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

if #available(macOS 12, *) {
    print("Browsing...")
    let instances = try await sd.lookup(DNSServiceQuery(type: .dnsSdServices))

    for instance in instances {
        print(instance)
    }
} else {
    fatalError("async-await requires macOS 12+")
}
