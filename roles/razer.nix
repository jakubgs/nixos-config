{ pkgs, ... }:

{
  hardware.openrazer = {
    enable = true;
    users = ["jakubgs"];
  };

  users.users.jakubgs.packages = with pkgs; [
    unstable.polychromatic
  ];
}
