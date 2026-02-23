# Description

Custom ISO livecd image for running from memory in ari-gapped way to handle operations on offline backups of GPG master keys.

# Testing

```sh
nix build '.#nixosConfigurations.airgapcd.config.system.build.vm'
./result/bin/run-airgapcd-vm
```

# Building

```sh
nix build '.#nixosConfigurations.airgapcd.config.formats.iso'
sudo dd if=result/nixos-*.iso of=/dev/sdX bs=4M oflag=sync status=progress
```

# Details

Here's some commands to generate master key, sub keys, and adjust expiry:
```sh
gpg --quick-generate-key 'joe@example.org' RSA4096 default none
gpg --quick-add-key "${FINGERPRINT}" RSA4096 auth 2y
gpg --quick-add-key "${FINGERPRINT}" RSA4096 encrypt 2y
gpg --quick-add-key "${FINGERPRINT}" RSA4096 sign 2y
gpg --quick-set-expire "${FINGERPRINT}" 2y '*'
```
