{ ... }:

{
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  users.extraGroups.vboxusers.members = [ "jakubgs" ];
}
