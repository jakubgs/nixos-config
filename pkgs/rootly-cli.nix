{ lib, buildGo124Module, fetchFromGitHub, installShellFiles, ... }:

buildGo124Module rec {
  pname = "rootly-cli";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "rootlyhq";
    repo = "rootly-cli";
    rev = "v${version}";
    hash = "sha256-UDPMv02aGoupZy0XY2ROfig5wTFf6qpMAg+uUUyu38c=";
  };

  vendorHash = "sha256-BE7i3A53JlzIEoH457nJKB0f/Sd3pct9Ck/cuNREUVA=";

  subPackages = [ "cmd/rootly" ];

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.commit=nix"
    "-X main.date=1970-01-01T00:00:00Z"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/rootly completion bash > rootly.bash
    $out/bin/rootly completion fish > rootly.fish
    $out/bin/rootly completion zsh > _rootly

    installShellCompletion --cmd rootly \
      --bash rootly.bash \
      --fish rootly.fish \
      --zsh _rootly
  '';

  doCheck = true;

  meta = {
    description = "Rootly CLI for managing incidents, alerts, services, teams, and on-call schedules";
    homepage = "https://github.com/rootlyhq/rootly-cli";
    license = lib.licenses.mit;
    mainProgram = "rootly";
  };
}
