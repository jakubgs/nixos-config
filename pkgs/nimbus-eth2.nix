{
  pkgs ? import <nixpkgs> { },
  # Options: nimbus_light_client, nimbus_validator_client, nimbus_signing_node
  makeTargets ? [ "nimbus_beacon_node" ],
  # WARNING: CPU optmizations that make binary not portable.
  nativeBuild ? false
}:

let
  inherit (pkgs) stdenv fetchgit lib which writeScriptBin;
in stdenv.mkDerivation rec {
  pname = "nimbus";
  version = "22.10.1";
  commit = "97a1cdc4";
  name = "${pname}-${version}-${commit}";

  src = fetchgit {
    url = "https://github.com/status-im/nimbus-eth2.git";
    rev = "v${version}";
    sha256 = "sha256-VmRzzYI+Fvvei4NMzlAugI5uMR46mTwDUqGTMjMhoR4=";
    fetchSubmodules = true;
  };

  buildInputs = let
    # Fix for Nim compiler calling 'git rev-parse' and 'lsb_release'.
    fakeGit = writeScriptBin "git" "echo $commit";
    fakeLsbRelease = writeScriptBin "lsb_release" "echo nix";
  in [ fakeGit fakeLsbRelease which ];

  enableParallelBuilding = true;

  NIMFLAGS = lib.optionalString (!nativeBuild) " -d:disableMarchNative";

  makeFlags = makeTargets;

  preBuildPhases = [ "buildCompiler" ];

  # Generate vendor/.nimble contents with correct paths.
  configurePhase = ''
    export EXCLUDED_NIM_PACKAGES=""
    export NIMBLE_LINK_SCRIPT=$PWD/vendor/nimbus-build-system/scripts/create_nimble_link.sh
    export NIMBLE_DIR=$PWD/vendor/.nimble
    export PWD_CMD=$(which pwd)
    patchShebangs scripts > /dev/null
    patchShebangs $PWD/vendor/nimbus-build-system/scripts > /dev/null
    for dep_dir in $(find vendor -type d -maxdepth 1); do
        pushd "$dep_dir" >/dev/null
        $NIMBLE_LINK_SCRIPT "$dep_dir"
        popd >/dev/null
    done
  '';

  # Nimbus uses it's own specific Nim version bound as a Git submodule.
  buildCompiler = ''
    # Necessary for nim cache creation
    export HOME=$PWD
    make -j$NIX_BUILD_CORES build-nim
    export PATH="$PWD/vendor/nimbus-build-system/vendor/Nim/bin:$PATH"
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
