{ pkgs, ... }:

{
  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Extra scripts
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin "usb_backup" ../../files/scripts/usb_backup.sh)
    (pkgs.writeScriptBin "iso_backup" ../../files/scripts/iso_backup.sh)
  ];
}
