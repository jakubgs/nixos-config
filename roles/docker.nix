{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "devicemapper";
    extraOptions = "--storage-opt dm.basesize=30G";
  };

  environment.systemPackages = with pkgs; [ docker-compose ];
}
