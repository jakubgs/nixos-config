{ pkgs, ... }:

let
  # builtins.exec expects stdout to be a Nix expression.
  passSh = pkgs.writeScript "pass" ''
    if command -v pass >/dev/null; then
      sudo -u jakubgs pass "$@" | awk '{ print "\""$0"\""}'
    else
      echo null; exit 0
    fi
  '';

  # We have to ignore if secrets.nix doesn't exit.
  secretsSh = pkgs.writeScript "cat" ''
    cat /etc/nixos/secrets.nix 2>/dev/null || echo '{}'
  '';
in pkgs.writeText "extra-builtins.nix" ''
  { exec, ... }:

  {
    pass = path: exec [ "${passSh}" path ];
    secrets = exec [ "${secretsSh}" ];
  }
''
