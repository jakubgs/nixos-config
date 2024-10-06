{
  pkgs ? import <nixpkgs> { },
  # Options: nimbus_light_client, nimbus_validator_client, nimbus_signing_node
  makeTargets ? [ "nimbus_beacon_node" ],
  # WARNING: CPU optmizations that make binary not portable.
  nativeBuild ? true,
  # Use unsable channel to get newer Nim.
  unstableNim ? if builtins.hasAttr "unstable" pkgs then pkgs.unstable.nim2 else pkgs.nim2
}:

assert pkgs.lib.assertMsg (unstableNim.version == "2.0.8")
  "Unable to build with Nim ${unstableNim.version}, only 2.0.8 allowed.";

let
  inherit (pkgs) stdenv fetchgit fetchurl lib which writeScriptBin;
in stdenv.mkDerivation rec {
  pname = "nimbus";
  version = "24.9.0";
  commit = "f54a0366";
  name = "${pname}-${version}-${commit}";

  src = fetchgit {
    url = "https://github.com/status-im/nimbus-eth2.git";
    rev = "v${version}";
    sha256 = "sha256-OaYGzOfjEmk0kNWDls8Lu6bfS1WxWY6yBxIrQH2yel0=";
    fetchSubmodules = true;
  };

  buildInputs = let
    # Fix for Nim compiler calling 'git rev-parse' and 'lsb_release'.
    fakeGit = writeScriptBin "git" "echo $commit";
    fakeLsbRelease = writeScriptBin "lsb_release" "echo nix";
  in [ fakeGit fakeLsbRelease which unstableNim ];

  enableParallelBuilding = true;

  NIMFLAGS = lib.optionalString (!nativeBuild) " -d:disableMarchNative";

  # WARNING: Version 1.6.10 is known to be stable.
  makeFlags = makeTargets ++ [ "USE_SYSTEM_NIM=1" ];

  # Generate the nimbus-build-system.paths file.
  configurePhase = ''
    patchShebangs scripts > /dev/null
    patchShebangs vendor/nimbus-build-system/scripts > /dev/null
    make nimbus-build-system-paths
  '';

  installPhase = ''
    mkdir -p $out/bin
    rm build/generate_makefile
    cp build/* $out/bin
  '';

  meta = with lib; {
    homepage = "https://nimbus.guide/";
    downloadPage = "https://github.com/status-im/nimbus-eth2/releases";
    changelog = "https://github.com/status-im/nimbus-eth2/blob/stable/CHANGELOG.md";
    description = "Nimbus is a lightweight client for the Ethereum consensus layer";
    longDescription = ''
      Nimbus is an extremely efficient consensus layer client implementation.
      While it's optimised for embedded systems and resource-restricted devices --
      including Raspberry Pis, its low resource usage also makes it an excellent choice
      for any server or desktop (where it simply takes up fewer resources).
    '';
    branch = "stable";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ jakubgs ];
    platforms = with platforms; x86_64 ++ arm ++ aarch64;
  };
}
