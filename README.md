# Swift DNS Service Discovery

An implementation of the [Swift Service Discovery API](https://github.com/apple/swift-service-discovery) using [DNS-based Service Discovery (DNS-SD)](https://en.wikipedia.org/wiki/Zero-configuration_networking#DNS-SD), also known as Bonjour, Zeroconf or Avahi.

Uses the `dns_sd` library, which on macOS is provided and on Linux requires the Avahi compatibility layer. On Ubuntu, the following package can be used:

```sh
sudo apt install libavahi-compat-libdnssd-dev
```

## Credits

The library draws inspiration from

- https://github.com/nallick/dns_sd, a high-level Swift wrapper of `dns_sd`
    - MIT-licensed (Copyright (c) 2019 Purgatory Design).
- https://github.com/rhx/CDNS_SD, a simpler Swift system library wrapper for `dns_sd`
    - BSD-2-licensed (Copyright (c) 2016, Rene Hexel)
