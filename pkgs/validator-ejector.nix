{ pkgs ? import <nixpkgs> { } }:

pkgs.yarn2nix-moretea.mkYarnPackage rec {
  pname = "validator-ejector";
  version = "1.6.0";

  nodejs = pkgs.nodejs_22;

  src = pkgs.fetchFromGitHub {
    owner = "lidofinance";
    repo = pname;
    rev = version;
    hash = "sha256-TMI+sv0/77RhqmqJ7bpqoWaeaGnbPv3cNMrK2Ortsl0=";
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildPhase = ''
    runHook preBuild

    rm -r node_modules/node-fetch
    cp -r deps/${pname}/node_modules/node-fetch node_modules/
    chmod 777 -R node_modules/node-fetch
    yarn --offline run build

    runHook postBuild
  '';

  postInstall = ''
    makeWrapper ${nodejs}/bin/node "$out/bin/${pname}" \
      --set NODE_PATH "$out/libexec/${pname}/node_modules" \
      --add-flags "$out/libexec/${pname}/node_modules/${pname}/dist/src/index.js"
  '';

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Service that loads LidoOracle events for validator exits.";
    homepage = "https://github.com/lidofinance/validator-ejector";
    license = licenses.mit;
    maintainers = with maintainers; [ jakubgs ];
  };
}
