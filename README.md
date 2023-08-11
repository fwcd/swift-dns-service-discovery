# Swift DNS Service Discovery

An implementation of the [Swift Service Discovery API](https://github.com/apple/swift-service-discovery) using [DNS-based Service Discovery (DNS-SD)](https://en.wikipedia.org/wiki/Zero-configuration_networking#DNS-SD), also known as Bonjour, Zeroconf or Avahi.

Uses the `dns_sd` library, which on macOS is provided and on Linux requires the Avahi compatibility layer. On Ubuntu, the following package can be used:

```sh
sudo apt install libavahi-compat-libdnssd-dev
```
