{ pkgs, config, ... }:

let
  hashedPass = config.lib.f.pass "hosts/users/jakubgs/pass-hash";
in {
  # Give extra permissions with Nix
  nix.trustedUsers = [ "jakubgs" ];

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
    hashedPassword = hashedPass;
    extraGroups = [
      "wheel" "audio" "dialout" "video" "disk"
      "adm" "tty" "systemd-journal" "docker"
      "networkmanager" "cdrom"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAotJTAk91kQ4skl7hDT5h5GwC/dWCfDXJiQMTw4QrgpNI7rxLhQbgorvN287bzrVig5xBQloMkkm9qqzOn2cv5L7iit8TT9mcrApDiqWBrb05jCm5cu1lINni/MWn5XfQMnE8YnWtwnW+ncd2EcwS9wVDabrTJPFjFYnMaHbl7Ls= jakubgs@lilim"
    ];
  };

  # allow of sudo without password
  security.sudo.wheelNeedsPassword = false;

  system.userActivationScripts = {
    jakubgsDotfiles = let 
      dotfilesSh = pkgs.substituteAll {
        src = ../files/dotfiles.sh;
        isExecutable = true;
        inherit (pkgs) bash git coreutils findutils gnused;
      };
    in "${dotfilesSh} 2> /dev/null";
  };
}
