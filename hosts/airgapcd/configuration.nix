{ pkgs, ... }:

{
  imports = [
    ../../roles/base/users.nix
    ../../roles/base/shell.nix
    ../../roles/base/nix.nix
    ../../roles/base/console.nix
    ../../roles/base/helpers.nix
    ../../roles/base/security.nix
    ../../roles/desktop/yubikey.nix
    ./harden.nix
    ./desktop.nix
  ];

  system.nixos.label = "airgapcd";

  # Message of the day
  users.motdFile = "/etc/motd";
   environment.etc."motd".text = ''
    Use following scripts to renew subkeys:

    mount_secret_cd
    renew_gpg_sub_keys
    # Here import the master and sub key backups.
    eval $(renew_gpg_sub_keys)
    umount_secret_cd
  '';

  environment.etc."zshrc".text = ''
    [[ -o interactive ]] || return
    [[ -n "$MOTD_SHOWN" ]] || return
    export MOTD_SHOWN=1
    cat /etc/motd
  '';

  # User autologin
  services.getty.autologinUser = "jakubgs";

  # Packages
  environment.systemPackages = with pkgs; [
    # Scripts
    (pkgs.writeScriptBin "mount_secret_cd"  ./scripts/mount_secret_cd.sh)
    (pkgs.writeScriptBin "umount_secret_cd" ./scripts/umount_secret_cd.sh)
    (pkgs.writeScriptBin "renew_gpg_sub_keys" ./scripts/renew_gpg_sub_keys.sh)
    # Base
    zsh sudo jq bc pv rename zip unzip wget curl
    # Storage
    parted gptfdisk udftools
    # Security
    gopass pass openssl cryptsetup
    # Misc
    git neovim fzf htop tmux silver-searcher
    # Desktop
    lxterminal rxvt-unicode rofi arandr
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
