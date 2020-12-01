{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "nimbus-eth2";
  version = "1.0.0";

  src = pkgs.fetchgit {
    url = "https://github.com/status-im/${pname}.git";
    rev = "v${version}";
    sha256 = "0a08k91b7vykns1hx5krmn2mwhk6fikiavmdw38il9v0zaki1q7v";
    fetchSubmodules = true;
  };

  buildInputs = with pkgs; [ which bash git nim ];

  NIMFLAGS = "-d:insecure -d:testnet_servers_image";
  CC = pkgs.gcc;

  buildPhases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];

  # Generate vendor/.nimble contents with correct paths
  configurePhase = ''
    export NIMBLE_LINK_SCRIPT=$PWD/vendor/nimbus-build-system/scripts/create_nimble_link.sh
    export NIMBLE_DIR=$PWD/vendor/.nimble
    export PWD_CMD=$(which pwd)
    for f in `find $PWD/vendor/nimbus-build-system/scripts -type f -name '*.sh'`; do
      patchShebangs $f
    done
    for dep_dir in $(find vendor -type d -maxdepth 1); do
        pushd "$dep_dir" >/dev/null
        $NIMBLE_LINK_SCRIPT "$dep_dir"
        popd >/dev/null
    done
  '';

  buildPhase = ''
    make nimbus_beacon_node nimbus_signing_process USE_SYSTEM_NIM=1
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/nimbus_beacon_node $out/bin
    cp build/nimbus_signing_process $out/bin
  '';
}
