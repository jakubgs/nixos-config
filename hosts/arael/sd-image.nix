{ config, pkgs, lib, ... }:
let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };
in {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image.nix>
  ];

  # building with emulation
  nixpkgs.system = "aarch64-linux";

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    consoleLogLevel = lib.mkDefault 7;
    kernelParams = ["cma=32M" "console=ttyS2,115200n8" "console=tty0"];
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel_vanilla_6_3.nix { });
  };

  sdImage = {
    # bzip2 compression takes loads of time with emulation, skip it.
    compressImage = false;
    populateFirmwareCommands = '''';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  # Important
  hardware.enableRedistributableFirmware = true;

  # Enable OpenSSH
  services.sshd.enable = true;
  networking.firewall.enable = false;

  # root autologin etc
  users.users.root.password = "root";
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";
  services.getty.autologinUser = lib.mkDefault "root";

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== cardno:9 020 049"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5NIT2SVFFjV+ZraPBES45z8wkJf769P7AXdZ4FiJw+DcXKawNJCUefeBQY5GVofVOzOHUrkYLqzxVJihIZJaDgeyME/4pLXYztkk9EOWdQSadxLJjWItMJULJrh5nnXzKxv5yy1SGJCTcMSXrvR6JRduu+KTHGncXJ2Ze6Bdgm63sOdfyPCITSC+nc4GexYLAQmBxXCwtKieqfWVmKpazlVDxAg3Q1h2UXOuLTjkWomvzVCggwhzHtN/STQMCH49PlW/VoIBlrpYqlmRGObsdBae4Bk/D5ZpisJi6w573RcF9q3VrqJTHLiSpntfVJEtsbmyiNNckIujQfRk2KYvSCK2iGP17hfCE9HmEfSZNWrKrMqKJ7gHOhXHJrszh6TtN9zmgomPvYolJBLz/2/JC8swfixHPMzxQa+P2NyqC0yWg8Xqd1JLWKLHsLwpEYvmOfyYIY8zOfk7y3OJX8h7D/fgbnG/V75EVuZDc8sqXTJpj3esoEsz8XVu9cVraAOodG4zYKFnoTomAzBJtImh6ghSEDGT5BAvDyFySyJGMibCsG5DwaLvZUcijEkKke7Z7OoJR4qp0JABhbFn0efd/XGo2ZyGtJsibSW7ugayibEK7bDaYAW3lNXgpcDqpBiDcJVQG/UhhCSSrTsG0IUSbvSsrDuF6gCJWVKt4+klvLw== openpgp:0x8F1C7F9B"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA6mutbRHO8VvZ61MYvjIVv1Re9NiJGE1piTQq4IFwXOvAi1HkXkMlsjmzYt+CEv0HmMGCHmdrw5xpqnDTWg18lM5RYLzrAv9hBOQ10IC+8FH2XWDKoyz+PBQsNEbbJ23QQtu0O5mpsOzI/KBT9CkiYUYlEBwHI0vNqsdHDLwv3Yt7PhauguXDHpYnwH/OseVHLBg2+/3aJIfOMVVRnhptQGYAhTNUZ9F1EwvQETMhM/vEsk8+o9B3tK/Ii/RD2EtVUlpRG4q6QTFbssLMImUfcdoggHsfCqjq3apUs8bR81oN9UVoYiP8tn5sWIUyRBxIEzXpqa4rx04KY8xNYqeZ jakub@status.im"
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAotJTAk91kQ4skl7hDT5h5GwC/dWCfDXJiQMTw4QrgpNI7rxLhQbgorvN287bzrVig5xBQloMkkm9qqzOn2cv5L7iit8TT9mcrApDiqWBrb05jCm5cu1lINni/MWn5XfQMnE8YnWtwnW+ncd2EcwS9wVDabrTJPFjFYnMaHbl7Ls= jakubgs@lilim"
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
