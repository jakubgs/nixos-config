{
  pkgs ? import <nixpkgs> { },
  # WARNING: CPU optmizations that make binary not portable.
  nativeBuild ? true
}:

let
  rev = "3a8abd60";
  fakeGit = pkgs.writeScriptBin "git" "echo ${rev}";
  fakeLsbRelease = pkgs.writeScriptBin "lsb_release" "echo nix";
in pkgs.gcc10Stdenv.mkDerivation rec {
  pname = "nimbus-eth2";
  version = "22.8.2";

  src = pkgs.fetchgit {
    url = "https://github.com/status-im/${pname}.git";
    rev = "v${version}";
    sha256 = "sha256-Xr5itpNnM38ab6vYO3xR2hrJCqgUFrb+CMZwv3RLnp0=";
    fetchSubmodules = true;
  };

  # Fix for Nim compiler calling 'git rev-parse' and 'lsb_release'.
  buildInputs = [ fakeGit fakeLsbRelease ];
  nativeBuildInputs = with pkgs; [ which ];

  enableParallelBuilding = true;
  dontStrip = true; # Leave debugging symbols in.

  NIMFLAGS = "--debugger:native"
    + pkgs.lib.optionalString (!nativeBuild) " -d:disableMarchNative";

  makeFlags = [ "nimbus_beacon_node" "ncli_db" ];

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
    cp build/ncli_db $out/bin
    cp build/nimbus_beacon_node $out/bin
  '';
}
