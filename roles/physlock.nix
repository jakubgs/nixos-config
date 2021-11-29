{ pkgs, ... }:

let
  lock = pkgs.writeScript "lock" ''
    exec sudo systemctl start physlock
  '';
in {
  # Lock other things too
  services.physlock = {
    enable = true;
    allowAnyUser = true;
    lockOn = {
      suspend = true;
      hibernate = true;
    };
  };

  # Automatically lock after 10 minutes
  services.xserver.xautolock = {
    enable = true;
    locker = "${lock}";
    time = 10;
  };

  environment.interactiveShellInit = "alias lock=${lock}";
  programs.zsh.interactiveShellInit = "alias lock=${lock}";
}
