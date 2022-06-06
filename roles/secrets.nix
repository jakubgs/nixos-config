{ config, pkgs, lib, ... }:

# Way to use password-store to get secrets when running Nix. For details see:
# https://elvishjerricco.github.io/2018/06/24/secure-declarative-key-management.html

let
  inherit (lib) assertMsg isString removeSuffix attrByPath;

  # Not all hosts have password-store and gpg keys.
  # Using secrets.nix as override for remote servers and setup.
  overrideSecrets = builtins.extraBuiltins.secrets;

  # Helper function for querying for secrets in Nix.
  # 1. Checks secrets.nix file overrides for path.
  # 2. Calls pass command for given path.
  secretFunc = path:
    assert (assertMsg (isString path) "Secret path has to be a string!");
    assert (assertMsg (path != "") "Secret path can't be empty!");
    let
      queryPass = path: removeSuffix "\n" (builtins.extraBuiltins.pass path);
    in
      attrByPath [ path ] (queryPass path) overrideSecrets;
in {
  # Allows for use of builtins.exec to call pass.
  nix.extraOptions = let
    # WARNING: Version 9.0.0 from unstable necessary for Nix 2.8.
    nix-plugins = pkgs.unstable.nix-plugins.override { nix = config.nix.package; };
  in ''
    plugin-files = ${nix-plugins}/lib/nix/plugins
    extra-builtins-file = ${import ./builtins.nix { inherit pkgs; }}
  '';

  # Make helper function vailable in module arguments.
  # WARNING: Can cause infinite recursion errors!
  _module.args.secret = secretFunc;
}
