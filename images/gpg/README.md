# Description

This ISO image is intended for running in memory to handle operations on offline backups of GPG master keys.

# Details

Here's some commands to generate master key, sub keys, and adjust expiry:
```
gpg --quick-generate-key 'joe@example.org' RSA4096 default none
gpg --quick-add-key "${FINGERPRINT}" RSA4096 auth 2y
gpg --quick-add-key "${FINGERPRINT}" RSA4096 encrypt 2y
gpg --quick-add-key "${FINGERPRINT}" RSA4096 sign 2y
gpg --quick-set-expire "${FINGERPRINT}" 2y '*'
```
