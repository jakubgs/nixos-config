# Description

This repo defines [NixOS](https://nixos.org/nixos/) configuration for my hosts.

# Usage

To deploy the configuration run:
```bash
cp example.secrets.nix secrets.nix
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

# Nix Packages

To use a custom `nixpkgs` location use the `-I` flag:
```
sudo nixos-rebuild switch -I nixpkgs=${HOME}/nixpkgs
```
