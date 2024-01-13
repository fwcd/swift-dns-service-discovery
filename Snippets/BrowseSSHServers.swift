import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

print("Browsing for SSH servers...")
sd.lookup(DNSServiceQuery(type: .sshTcp)) { instances in
    for instance in try! instances.get() {
        print(instance)
    }
}

dispatchMain()
