# Description

These keys are generated purely for the sake of logging into `initrd` image when boot fails.

We cannot use real host private keys with `boot.initrd.network.ssh.hostKeys` because they would be exposed in the `/nix/store`.
