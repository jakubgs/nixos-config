{ config, ... }:

{
 services.comin = {
   enable = true;
   desktop.enable = true;
   submodules = false;
   machineId = null;
   buildConfirmer.mode = "without";
   deployConfirmer.mode = "manual";
   gpgPublicKeyPaths = [
     "${../../files/keys/30236E0B5767C9C5DC9E74A76295CD4EBA31C3EA.gpg}"
   ];
   remotes = [
     {
       name = "origin";
       url = "https://github.com/jakubgs/nixos-config";
       poller.period = 60;
       branches = {
         main.name = "master";
         testing.name = "test/${config.services.comin.hostname}";
       };
     }
   ];
 };
}
