# Description

This repo defines [NixOS](https://nixos.org/nixos/) configuration for my hosts.

# Usage

Symlink the repo to `/etc/nixos`:
```bash
sudo ln -s $(realpath nixos-config) /etc/nixos
```
Deploy the configuration for given host using `--flake`:
```bash
sudo nixos-rebuild switch --flake '/etc/nixos#caspair'
```
If the hostname matches `--flake` is not necessary.

# Secrets

Secrets are fetched encrypted using [agenix](https://github.com/ryantm/agenix) with public Ed25519 keys of hosts.
