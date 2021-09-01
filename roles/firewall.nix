{ ... }:

{
  networking.firewall = {
    enable = true;
    extraCommands = ''
      iptables -P INPUT DROP
      iptables -P FORWARD DROP
    '';
  };
}
