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

Secrets are fetched by [`roles/secrets.nix`](roles/secrets.nix):

1. By calling [`pass`](https://www.passwordstore.org/) for given path
2. Checking `secrets.nix` as fallback

Use [`example.secrets.nix`](example.secrets.nix) to create `secrets.nix`
