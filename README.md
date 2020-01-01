# Description

This repo defines [NixOS](https://nixos.org/nixos/) configuration for my hosts.

# Usage

To deploy the configuration run:
```bash
cp secrets.example.nix secrets.nix
vim secrets.nix
sudo ./symlink "${HOSTNAME}"
```
That should symlink the necessary host-specific files:

* `hosts/${HOSTNAME}/configuration.nix`
* `hosts/${HOSTNAME}/hardware.configuration.nix`

To the repo root and link the repo root to `/etc/nixos`.

To apply the changes simply use:
```bash
sudo nixos-rebuild switch
```
