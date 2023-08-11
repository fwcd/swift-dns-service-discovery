import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

print("Browsing...")
sd.lookup(DNSService(type: .dnsSdServices)) { instances in
    print("Instances: \(instances)")
}

dispatchMain()
