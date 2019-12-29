# Description

This repo defines [NixOS](https://nixos.org/nixos/) configuration for my hosts.

# Usage

To deploy the configuration run:
```bash
cp secrets.example.nix secrets.nix
vim secrets.nix
sudo ./symlink
```
That should symlink `configuration.nix` and `hardware.configuration.nix` at repo root and link the repo root to `/etc/nixos`.