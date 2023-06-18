# Description

Configuration for Hetzner `CAX21` cloud host.

# Hardware

* ARM64 4 Cores
* RAM 8 GB
* SSD 80 GB

# Installation

Using [`nixos-infect`](https://github.com/elitak/nixos-infect) by setting User Data to:
```
#!/bin/sh
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect \
    | PROVIDER=hetznercloud NIX_CHANNEL=nixos-22.11 bash 2>&1 \
    | tee /tmp/infect.log
```
