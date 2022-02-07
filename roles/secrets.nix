{ pkgs, lib, ... }:

# Way to use password-store to get secrets when running Nix. For details see:
# https://elvishjerricco.github.io/2018/06/24/secure-declarative-key-management.html

let
  inherit (lib) assertMsg isString removeSuffix attrByPath;

  # builtins.exec expects stdout to be a Nix expression.
  sudoPass = pkgs.writeScript "pass" ''
    sudo -u jakubgs pass "$@" | awk '{ print "\""$0"\""}'
  '';

  # We have to ignore if secrets.nix doesn't exit.
  catWrap = pkgs.writeScript "cat" ''
    cat "$@" 2>/dev/null || echo '{}'
  '';

  # Not all hosts have password-store and gpg keys.
  # Using secrets.nix as override for remote servers and installations.
  # FIXME: Without exec flake builds don't see uncommited files.
  overrideSecrets = builtins.exec [ catWrap "/etc/nixos/secrets.nix" ];

  # Helper function for querying for secrets in Nix.
  # 1. Checks secrets.nix file overrides for path.
  # 2. Calls pass command for given path.
  secretFunc = path:
    assert (assertMsg (isString path) "Secret path has to be a string!");
    assert (assertMsg (path != "") "Secret path can't be empty!");
    let
      queryPass = path: removeSuffix "\n" (builtins.exec [ sudoPass path ]);
    in
      attrByPath [ path ] (queryPass path) overrideSecrets;
in {
  # Allows for use of builtins.exec to call pass.
  # TODO: Replace with nix-plugins in the future.
  nix.extraOptions = ''
    allow-unsafe-native-code-during-evaluation = true
  '';

  # Make helper function vailable in module arguments.
  # WARNING: Can cause infinite recursion errors!
  _module.args.secret = secretFunc;
}
