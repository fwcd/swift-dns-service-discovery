import DNSServiceDiscovery
import Dispatch

let sd = DNSServiceDiscovery()

print("Subscribing to AirPlay servers...")
let token = sd.subscribe(to: DNSServiceQuery(type: .airplayTcp)) { instances in
    print(String(repeating: "-", count: 80))
    for instance in try! instances.get() {
        print(instance)
    }
} onComplete: { reason in
    print("Completed: \(reason)")
}

dispatchMain()
