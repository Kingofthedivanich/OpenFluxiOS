# OpenFluxiOS (fork)

## Description

SwiftUI iOS client for the core fork
[Kingofthedivanich/OpenFlux-WebGui](https://github.com/Kingofthedivanich/OpenFlux-WebGui),
split out into its own repo (previously lived at that repo's `ios-app/`) to
mirror the paired
[Android client](https://github.com/Kingofthedivanich/OpenFluxAndroid)'s
separate-repo setup. Links the core's Go transport as a static library
(`liboflux.a`) rather than talking to it over a network protocol.

## How it works

- Two ways to run a tunnel: a local SOCKS5 proxy (`127.0.0.1:<port>`, via
  `OpenFluxStartClient`), or a system-wide VPN through a
  `NEPacketTunnelProvider` network extension (`OpenFluxTunnel/`,
  `OpenFluxStartPacketTunnel`) that routes the whole device.
- Transports: Yandex.Docs and MAX (`oneme`).
- Encryption is optional: an empty peer-key field means plaintext (the app
  passes `--allow-plaintext` automatically); paste the exit node's public
  key to turn on a Noise NKpsk0 handshake, with an optional PSK to further
  close that tunnel. The VPN extension runs in its own process, so its
  peer-key/PSK cross over through `providerConfiguration` rather than
  shared globals.

## Install guide

Requires Xcode, [xcodegen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`), and Go (version from the core repo's `go.mod`).

Build the Go static library from a checkout of the core repo:

```bash
./build-openflux.sh /path/to/OpenFlux-WebGui
```

Installs `Lib/liboflux.a` and the cgo-generated `Lib/liboflux.h`.

Generate and open the Xcode project:

```bash
xcodegen generate
open OpenFlux.xcodeproj
```

Full release pipeline (build the lib, archive, export an App Store IPA):

```bash
./build-app.sh /path/to/OpenFlux-WebGui
```

Produces `build/export/OpenFlux.ipa`. See
[DISTRIBUTION.ru.md](DISTRIBUTION.ru.md) for the TestFlight upload steps
(team `8GQH8GQ252`, bundle id `com.p1neapplexpress-saharev.openflux`).
