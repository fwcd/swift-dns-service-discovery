import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

print("Resolving all AirPlay servers...")
sd.lookup(DNSServiceQuery(type: .airplay)) { instances in
    for instance in try! instances.get() {
        sd.lookup(DNSServiceQuery(instance)) { resolved in
            print("Resolved \(instance.name) to \(resolved)")
        }
    }
}

dispatchMain()
