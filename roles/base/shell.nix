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
  environment.systemPackages = let
    mkScriptPkg = name: src: deps: pkgs.replaceVarsWith {
      inherit name src;
      dir = "bin";
      isExecutable = true;
      replacements = {
        runtimeShell = pkgs.runtimeShell;
        binPath = pkgs.lib.makeBinPath (with pkgs;
          [coreutils util-linux gnugrep cryptsetup] ++ deps
        );
      };
    };
  in with pkgs; [
    (mkScriptPkg "usb_backup" ../../files/scripts/usb_backup.sh [e2fsprogs])
    (mkScriptPkg "iso_backup" ../../files/scripts/iso_backup.sh [udftools])
  ];
}
