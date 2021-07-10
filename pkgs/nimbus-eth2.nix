{
  pkgs ? import <nixpkgs> { },
  # WARNING: This makes binary not portable.
  nativeBuild ? true
}:

let
  rev = "07a1c571";
  fakeGit = pkgs.writeScriptBin "git" "echo ${rev}";
in pkgs.stdenv.mkDerivation rec {
  pname = "nimbus-eth2";
  version = "1.4.1";

  src = pkgs.fetchgit {
    url = "https://github.com/status-im/${pname}.git";
    rev = "v${version}";
    sha256 = "1ywppf340c7hfzkrxwdvsdhsqck9hxly2p8nfxpa9sr0h0sppimn";
    fetchSubmodules = true;
  };

  dontStrip = true; # leave debugging symbols in

  nativeBuildInputs = with pkgs; [ which nim ];

  NIMFLAGS = "-d:testnet_servers_image --debugger:native" 
    + pkgs.lib.optionalString (!nativeBuild) " -d:disableMarchNative";

  buildPhases = [ "unpackPhase" "configurePhase" "buildPhase" "fixupPhase" "installPhase" ];

  # Generate vendor/.nimble contents with correct paths
  configurePhase = ''
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

  buildPhase = ''
    # Fix for Nim compiler calling git rev-parse
    export PATH=$PATH:${fakeGit}/bin
    make -j$NIX_BUILD_CORES \
      nimbus_beacon_node nimbus_signing_process ncli_db \
      NIMFLAGS='${NIMFLAGS}' \
      USE_LIBBACKTRACE=0 \
      USE_SYSTEM_NIM=1
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/ncli_db $out/bin
    cp build/nimbus_beacon_node $out/bin
    cp build/nimbus_signing_process $out/bin
  '';
}
