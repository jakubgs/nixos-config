# Description

Configuration for Raspberry Pi 4B device.

# Hardware

* Broadcom BCM2711
* Quad-core ARM-8 Cortex-A72
* RAM 8 GB

# Building

```sh
IMAGE=$(nix build .\#nixosConfigurations.leliel.config.formats.iso)
unzstd -f $IMAGE --stdout | sudo dd of=/dev/sdj bs=1M status=progress
```

# SD Card Creation

To create the SD card image I've used the following instruction:
https://gist.github.com/chrisanthropic/2e6d3645f20da8fd4c1f122113f89c06

And used this repo:
https://github.com/Robertof/nixos-docker-sd-image-builder
