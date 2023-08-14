# Swift DNS Service Discovery

An implementation of the [Swift Service Discovery API](https://github.com/apple/swift-service-discovery) using [DNS-based Service Discovery (DNS-SD)](https://en.wikipedia.org/wiki/Zero-configuration_networking#DNS-SD), also known as Bonjour, Zeroconf or Avahi.

Uses the `dns_sd` library, which on macOS/Windows is provided by Bonjour and on Linux requires the Avahi compatibility layer. On Ubuntu, the following package can be used:

```sh
sudo apt install libavahi-compat-libdnssd-dev
```

## Credits

The library draws inspiration from

- https://github.com/nallick/dns_sd, a high-level Swift wrapper of `dns_sd`
    - MIT-licensed (Copyright (c) 2019 Purgatory Design).
- https://github.com/rhx/CDNS_SD, a simpler Swift system library wrapper for `dns_sd`
    - BSD-2-licensed (Copyright (c) 2016, Rene Hexel)

The following documentation on the `dns_sd` library was also incredibly helpful:

- [Apple's documentation archive](https://developer.apple.com/library/archive/documentation/Networking/Conceptual/dns_discovery_api/Articles/browse.html#//apple_ref/doc/uid/TP40002486-SW1), describing the low-level DNS-SD API
- [DNS Service Discovery on Windows](https://marknelson.us/posts/2011/10/25/dns-service-discovery-on-windows.html), providing an example-oriented overview of the library and an explanation of how the callbacks are driven
