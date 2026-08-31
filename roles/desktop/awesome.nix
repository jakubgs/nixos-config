{ pkgs, ... }:

{
  services.xserver.windowManager.awesome.enable = true;

  services.displayManager.defaultSession = "none+awesome";

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "notify-send";
      runtimeInputs = with pkgs; [ awesome gawk ];
      runtimeEnv.AWESOME_USER = "jakubgs";
      text = builtins.readFile ../../files/scripts/notify-send.sh;
    })
  ];
}
