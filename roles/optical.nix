{ pkgs, lib, ... }:

{
  users.users.sochan.packages = with pkgs; [
    brasero dvdplusrwtools udftools cryptsetup
  ];
}
