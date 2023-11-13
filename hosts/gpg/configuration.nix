{ channels, pkgs, lib, ... }:

{
  imports = [
    "${channels.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
    ../../roles/nix.nix
    ../../roles/secrets.nix
    ../../roles/users.nix
    ../../roles/yubikey.nix
  ];

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Packages
  environment.systemPackages = with pkgs; [
    # Base
    zsh sudo bc pv rename zip unzip wget curl
    # Storage
    parted gptfdisk
    # Security
    gopass pass openssl
    # Misc
    git neovim fzf htop tmux silver-searcher
  ];

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Password entry method.
  programs.gnupg.agent.pinentryFlavor = lib.mkForce "curses";

  # Disable all suspend methods.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
