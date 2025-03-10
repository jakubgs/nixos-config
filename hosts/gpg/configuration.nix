{ channels, pkgs, lib, ... }:

{
  imports = [
    ../../roles/base/nix.nix
    ../../roles/base/console.nix
    ../../roles/base/helpers.nix
    ../../roles/base/security.nix
    ../../roles/yubikey.nix
  ];

  # Message of the day
  users.motd = ''
    Use following scripts to renew subkeys:

    mount_secret_cd
    renew_gpg_sub_keys
    # Here import the master and sub key backups.
    eval $(renew_gpg_sub_keys)
    umount_secret_cd
  '';

  # root autologin, root password set to root
  services.getty.autologinUser = "root";
  users.users.root.password = "root";

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Packages
  environment.systemPackages = with pkgs; [
    # Scripts
    (pkgs.writeScriptBin "mount_secret_cd"  ./mount_secret_cd.sh)
    (pkgs.writeScriptBin "umount_secret_cd" ./umount_secret_cd.sh)
    (pkgs.writeScriptBin "renew_gpg_sub_keys" ./renew_gpg_sub_keys.sh)
    # Console
    rxvt-unicode rofi
    # Base
    zsh sudo bc pv rename zip unzip wget curl
    # Storage
    parted gptfdisk
    # Security
    gopass pass openssl cryptsetup
    # Misc
    git neovim fzf htop tmux silver-searcher
  ];

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Password entry method.
  programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-curses;

  # Disable all suspend methods.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Disable networking
  networking.useDHCP = lib.mkForce false;
  networking.interfaces = {};

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
