import DNSServiceDiscovery

let sd = DNSServiceDiscovery()
sd.lookup(DNSService(type: .dnsSdServices)) { instances in
    print(instances)
}
