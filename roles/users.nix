{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in {
  users.groups.sochan = {
    gid = 1000;
    name = "sochan";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sochan = {
    uid = 1000;
    createHome = true;
    isNormalUser = true;
    useDefaultShell = true;
    group = "sochan";
    hashedPassword = secrets.userHashedPassword;
    extraGroups = [ "wheel" "audio" "video" "disk" "adm" "tty" "systemd-journal" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAotJTAk91kQ4skl7hDT5h5GwC/dWCfDXJiQMTw4QrgpNI7rxLhQbgorvN287bzrVig5xBQloMkkm9qqzOn2cv5L7iit8TT9mcrApDiqWBrb05jCm5cu1lINni/MWn5XfQMnE8YnWtwnW+ncd2EcwS9wVDabrTJPFjFYnMaHbl7Ls= sochan@lilim"
    ];
  };

  # allow of sudo without password
  security.sudo.wheelNeedsPassword = false;

  system.activationScripts.dotfiles = lib.noDepEntry ''
    _dotfiles=${config.users.users.sochan.home}/dotfiles 
    if [[ -d "$_dotfiles" ]]; then
      echo "dotfiles already configured"
    else
      echo "fetching and configuring dotfiles..."
      ${pkgs.sudo}/bin/sudo -i -u sochan bash -c "GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone git@github.com:jakubgs/dotfiles.git && $_dotfiles/bin/symlinkconf"
    fi
  '';
}
