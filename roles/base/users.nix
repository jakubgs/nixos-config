{ pkgs, lib, secret, config, ... }:

{
  age.secrets."hosts/users/jakubgs/pass-hash" = {
    file = ../../secrets/hosts/users/jakubgs/pass-hash.age;
  };

  age.secrets."service/nixos-activation/key" = {
    file = ../../secrets/service/nixos-activation/key.age;
    owner = "jakubgs";
  };

  # Give extra permissions with Nix.
  nix.settings.trusted-users = [ "jakubgs" ];

  # Do not allow password changes.
  users.mutableUsers = false;

  users.groups.jakubgs = {
    gid = 1000;
    name = "jakubgs";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jakubgs = {
    uid = 1000;
    createHome = true;
    isNormalUser = true;
    useDefaultShell = true;
    group = "jakubgs";
    hashedPasswordFile = secret "hosts/users/jakubgs/pass-hash";
    extraGroups = [
      "wheel" "audio" "dialout" "video" "disk"
      "adm" "tty" "systemd-journal" "docker"
      "networkmanager" "cdrom"
    ];
    openssh.authorizedKeys.keys = [
      # CURRENT
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== cardno:9 020 049"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUXvuXqZwlLOSxYqthiWF1J5U4E93SUGDu7gk4Ok30T jakubgs@caspair"
      # LEGACY
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoSmZuJeFZCrLP5ErZUnWNzrDymrIdfSnIaZi713Gj1frzu7qUN1DTEZkzR4rz3tx3jy8iez0z1dF88sQYyHxq/8uVGiEzxyzLv+fnO+N9dCKHGKw0zfMsio2d12ca9gXFvs0MasJJ7iNfem2USaKtL4tIbaZ/too+mnwwdnIFDZ4vU34s38L/mosKB30kndDJognxNfDmdyh+dRsKlRg92wzI/QG7cDFYTLRuPcTL0WTnmWaFfazqs5ukocnNle7xRW/XqrBVUnACldPPfvWwRlAjYAtKhJPQZAPZF2qonn43xx6maJY1fgfgrtUY7QAMC/NzmpmhrDROazyEhQD/R+D+WBrYhp1FX8d8XkNJrEJrnHrd4NxDWw9tF5Z49a5nkUbD4l9gtbAMooFTqszRicQ8Y0F52XMr0PQY/u/wm6S3qSORcJkdwTsBQUk+SCOkPkjy6OfyggU0ZtD+TYkj0FPYc6bwk1xxAROqpclzEfGpVODqdX56Lio00OB6cf0= openpgp:0x1571357C"
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAotJTAk91kQ4skl7hDT5h5GwC/dWCfDXJiQMTw4QrgpNI7rxLhQbgorvN287bzrVig5xBQloMkkm9qqzOn2cv5L7iit8TT9mcrApDiqWBrb05jCm5cu1lINni/MWn5XfQMnE8YnWtwnW+ncd2EcwS9wVDabrTJPFjFYnMaHbl7Ls= jakubgs@lilim"
    ];
  };

  # allow of sudo without password
  security.sudo.wheelNeedsPassword = false;

  system.userActivationScripts = {
    jakubgsDotfiles = let
      dotfilesSh = pkgs.replaceVarsWith {
        src = ../../files/dotfiles.sh;
        isExecutable = true;
        replacements = {
          sshKey = secret "service/nixos-activation/key";
          dotfilesUrl = "git@github.com:jakubgs/dotfiles.git";
          dotfilesBranch = "master";
          shell = "${pkgs.bash}/bin/bash";
          inherit (pkgs) git;
        };
      };
    in "${dotfilesSh}";
  };
}
