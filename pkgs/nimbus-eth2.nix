{
  pkgs ? import <nixpkgs> { },
  # WARNING: This makes binary not portable.
  nativeBuild ? true
}:

let
  rev = "88532c61";
  fakeGit = pkgs.writeScriptBin "git" "echo ${rev}";
  fakeLsbRelease = pkgs.writeScriptBin "lsb_release" "echo nix";
in pkgs.gcc10Stdenv.mkDerivation rec {
  pname = "nimbus-eth2";
  version = "22.6.0";

  src = pkgs.fetchgit {
    url = "https://github.com/status-im/${pname}.git";
    rev = "v${version}";
    sha256 = "sha256-k1Uvdv2w9Ujj18Jp0sQdZOc48isObS2Cnea3jnbl2oI=";
    fetchSubmodules = true;
  };

  dontStrip = true; # leave debugging symbols in

  nativeBuildInputs = with pkgs; [ which ];

  NIMFLAGS = "-d:testnet_servers_image --debugger:native" 
    + pkgs.lib.optionalString (!nativeBuild) " -d:disableMarchNative";

  # Fix for Nim compiler calling git rev-parse
  buildInputs = [ fakeGit fakeLsbRelease ];

  preBuildPhases = [ "buildCompiler" ];
  buildPhases = [ "unpackPhase" "configurePhase" "buildPhase" "fixupPhase" "installPhase" ];

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
    make build-nim
    export PATH="$PWD/vendor/nimbus-build-system/vendor/Nim/bin:$PATH"
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES \
      nimbus_beacon_node ncli_db \
      NIMFLAGS='${NIMFLAGS}' \
      USE_LIBBACKTRACE=0 \
      USE_SYSTEM_NIM=1
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/ncli_db $out/bin
    cp build/nimbus_beacon_node $out/bin
  '';
}
