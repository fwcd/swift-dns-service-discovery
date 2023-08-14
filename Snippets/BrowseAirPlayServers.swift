import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

print("Browsing for AirPlay servers...")
sd.lookup(DNSServiceQuery(type: .airplay)) { instances in
    for instance in try! instances.get() {
        print(instance)
    }
}

dispatchMain()
