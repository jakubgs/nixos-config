{ ... }:

{
  # User configuration management
  home-manager.users.sochan = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      pkgs.atool pkgs.httpie
    ];

    programs = {
      zsh = { 
        enable = true;
        autocd = true;
        defaultKeymap = "vicmd";
        enableAutosuggestions = true;
        initExtra = builtins.readFile "${pkgs.fetchurl "https://raw.githubusercontent.com/jakubgs/dotfiles/master/.zshrc"}";
      };

      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        #configure = {
        #  customRC = builtins.readFile (pkgs.fetchurl "https://raw.githubusercontent.com/jakubgs/dotfiles/master/.config/nvim/init.vim");
        #};
      };
    };
  };
}
