{ pkgs, lib, config, ... }:

let
  inherit (lib) concatStringsSep splitString drop;
  newLib = {
    pathToMountUnit = path: (
      concatStringsSep "-" (drop 1 (splitString "/" path))
    ) + ".mount";
  };
in {
  # Helpers avaialble under pkgs.lib.
  nixpkgs.overlays = [
    (_: prev: { lib = prev.lib // newLib; })
  ];

  # Wrap desktop apps for use in Wayland
  _module.args.wrapWithFlags = package: flags:   let
    binary = builtins.baseNameOf (lib.getExe package);
  in pkgs.symlinkJoin {
    name = "${package.pname}-wrapped";
    paths = [ package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/${binary}" \
        ${lib.escapeShellArgs (lib.concatMap (flag: [ "--add-flags" flag ]) flags)}
    '';
  };

  # Make helper function vailable in module arguments.
  # WARNING: Can cause infinite recursion errors!
  _module.args.secret = name: config.age.secrets."${name}".path;
}
