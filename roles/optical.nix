{ pkgs, lib, ... }:

{
  users.users.jakubgs.packages = with pkgs; [
    brasero dvdplusrwtools udftools cryptsetup
  ];
}
