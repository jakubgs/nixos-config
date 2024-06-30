{ pkgs, ... }:

{
  # Systemd in initrd. Useful for debugging boot issues.
  boot.initrd = {
    systemd = {
      enable = true;
      emergencyAccess = true;
      storePaths = with pkgs; [ util-linux pciutils ];
      extraBin = {
        fdisk = "${pkgs.util-linux}/bin/fdisk";
        lsblk = "${pkgs.util-linux}/bin/lsblk";
        lspci = "${pkgs.pciutils}/bin/lspci";
      };
    };

    network.ssh = {
      enable = true;
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== openpgp:0x64A63589"
      ];
      # Do not add real host keys to /nix/store.
      hostKeys [
        "/etc/secrets/initrd/ssh_host_rsa_key"
        "/etc/secrets/initrd/ssh_host_ed25519_key"
      ]
    };
  };
}
