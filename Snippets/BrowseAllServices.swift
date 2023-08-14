import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

print("Browsing...")
sd.lookup(DNSServiceQuery(type: .dnsSdServices)) { instances in
    for instance in try! instances.get() {
        print(instance)
    }
}

dispatchMain()
