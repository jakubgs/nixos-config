{ pkgs, ... }:

{
  # Lock screen with slock
  programs.slock.enable = true;

  # Lock other things too
  services.physlock = {
    enable = true;
    allowAnyUser = true;
  };

  # Automatically lock after 10 minutes
  services.xserver.xautolock = {
    enable = true;
    locker = "${pkgs.slock}/bin/slock";
    time = 10;
  };
}
