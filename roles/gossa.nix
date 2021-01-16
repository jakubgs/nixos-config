{ ... }:

{
  imports = [ ../services/gossa.nix ];

  services.gossa = {
    enable = true;
    verbose = true;
    dataDir = "/mnt/photos";
    urlPrefix = "/gossa/";
  };
}
