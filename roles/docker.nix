{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    extraOptions = "--storage-opt dm.basesize=20G";
  };

  environment.systemPackages = with pkgs; [ docker-compose ];
}
