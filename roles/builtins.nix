{ pkgs, ... }:

let
  # builtins.exec expects stdout to be a Nix expression.
  passSh = pkgs.writeScript "pass" ''
    sudo -u jakubgs pass "$@" | awk '{ print "\""$0"\""}'
  '';

  # We have to ignore if secrets.nix doesn't exit.
  secretsSh = pkgs.writeScript "cat" ''
    cat ./secrets.nix 2>/dev/null || echo '{}'
  '';
in pkgs.writeText "example-builtins.nix" ''
  { exec, ... }:

  {
    pass = path: exec [ "${passSh}" path ];
    secrets = exec [ "${secretsSh}" ];
  }
''
