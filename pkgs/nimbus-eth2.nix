{
  pkgs ? import <nixpkgs> { },
  # Options: nimbus_light_client, nimbus_validator_client, nimbus_signing_node
  makeTargets ? [ "nimbus_beacon_node" "nimbus_validator_client" ],
  # WARNING: CPU optmizations that make binary not portable.
  nativeBuild ? true,
  stableNim ? pkgs.nim-2_2
}:

assert pkgs.lib.assertMsg (stableNim.version == "2.2.4")
  "Unable to build with Nim ${stableNim.version}, only 2.2.4 allowed.";

let
  inherit (pkgs) stdenv fetchgit fetchurl lib which writeScriptBin;
in stdenv.mkDerivation rec {
  pname = "nimbus";
  version = "25.6.0";
  commit = "c00f35a9";
  name = "${pname}-${version}-${commit}";

  src = fetchgit {
    url = "https://github.com/status-im/nimbus-eth2.git";
    rev = "v${version}";
    sha256 = "sha256-12aqzZndrYf3WQ3W9vW2M4pNQpW4+X6C2s1+dN1UvjM=";
    fetchSubmodules = true;
  };

  buildInputs = let
    # Fix for Nim compiler calling 'git rev-parse' and 'lsb_release'.
    fakeGit = writeScriptBin "git" "echo $commit";
    fakeLsbRelease = writeScriptBin "lsb_release" "echo nix";
  in [ fakeGit fakeLsbRelease which stableNim ];

  enableParallelBuilding = true;

  NIMFLAGS = lib.optionalString (!nativeBuild) " -d:disableMarchNative";

  # WARNING: Version 2.0.12 is known to be stable.
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
